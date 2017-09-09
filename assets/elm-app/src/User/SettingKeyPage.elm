module User.SettingKeyPage exposing (..)

import Http
import Html
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit, onClick)
import Task exposing (Task)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, optional)
import User.SessionData as Session exposing (Session)
import User.SettingRequest as SettingRequest
import User.SettingKeyData as Key exposing (Key)
import Helpers.Page.Errored as Errored exposing (PageLoadError)
import Helpers.Request.ErrorsData as ErrorsData
import View
import Helpers.Views.Form as Form
import Util exposing ((=>))


type alias Model =
    { keys : List Key
    , sshFormOpened : Bool
    , newTitle : String
    , newKey : String
    , errors : List ( String, String )
    }


type Msg
    = OpenNewSSHForm
    | SubmitForm
    | SetTitle String
    | SetKey String
    | KeyCreated (Result Http.Error Key)


initShow : Session -> Task PageLoadError Model
initShow session =
    let
        authToken =
            Session.maybeAuthToken session

        username =
            case session.user of
                Just user ->
                    user.username

                Nothing ->
                    ""

        handleLoadError e =
            Errored.pageLoadError View.Other "Keys are currently unavailable."
    in
        SettingRequest.listKeys username authToken
            |> Http.toTask
            |> Task.mapError handleLoadError
            |> Task.map
                (\keysList ->
                    { keys = keysList
                    , sshFormOpened = False
                    , newTitle = ""
                    , newKey = ""
                    , errors = []
                    }
                )


updateShow : Session -> Msg -> Model -> ( Model, Cmd Msg )
updateShow session msg model =
    case msg of
        OpenNewSSHForm ->
            { model | sshFormOpened = True }
                => Cmd.none

        SetTitle title ->
            { model | newTitle = title }
                => Cmd.none

        SetKey key ->
            { model | newKey = key }
                => Cmd.none

        SubmitForm ->
            let
                authToken =
                    Session.maybeAuthToken session

                username =
                    case session.user of
                        Just user ->
                            user.username

                        Nothing ->
                            ""

                req =
                    { title = model.newTitle, key = model.newKey }

                cmdToCreateKey =
                    SettingRequest.newKey username req authToken
                        |> Http.send KeyCreated
            in
                { model | errors = [] }
                    => cmdToCreateKey

        KeyCreated (Err error) ->
            let
                errorMessages =
                    ErrorsData.httpErrorToList "key creation" error errorsDecoder
            in
                { model | errors = List.map (\errorMessage -> "Form" => errorMessage) errorMessages }
                    => Cmd.none

        KeyCreated (Ok key) ->
            let
                allKeys =
                    List.append model.keys [ key ]
            in
                { model | keys = allKeys, sshFormOpened = False, newTitle = "", newKey = "" }
                    => Cmd.none


errorsDecoder : Decoder (List String)
errorsDecoder =
    decode (\title key -> List.concat [ title, key ])
        |> ErrorsData.optionalError "title"
        |> ErrorsData.optionalError "key"


viewShow : Session -> Model -> Html Msg
viewShow session model =
    div [ class "settings-keys-page" ]
        [ h1 [ class "text-xs-center" ]
            [ text ("SSH keys")
            , button
                [ class "btn btn-success btn-sm"
                , onClick OpenNewSSHForm
                ]
                [ text "New SSH key" ]
            ]
        , div [] (viewListKeys model)
        , View.viewIf model.sshFormOpened (addKeyForm model)
        ]


addKeyForm : Model -> Html Msg
addKeyForm model =
    Html.form [ onSubmit SubmitForm ]
        [ Form.viewErrors model.errors
        , Form.input
            [ class "form-control"
            , placeholder "Title"
            , onInput SetTitle
            ]
            []
        , Form.textarea
            [ style [ ( "height", "200px" ) ]
            , placeholder "Key begins with 'ssh-rsa', 'ssh-dss', 'ssh-ed25519', 'ecdsa-sha2-nistp256', 'ecdsa-sha2-nistp384', or 'ecdsa-sha2-nistp521'"
            , cols 40
            , rows 20
            , onInput SetKey
            ]
            []
        , button
            [ class "btn btn-success btn-sm" ]
            [ text "Add SSh key" ]
        ]


viewListKeys : Model -> List (Html Msg)
viewListKeys model =
    List.map (\key -> div [] [ text key.title ]) <|
        model.keys
