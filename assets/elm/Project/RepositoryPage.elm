module Project.RepositoryPage exposing (..)

import Html
import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit, onClick)
import Debug
import Task exposing (Task)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, optional)
import Helpers.Views.Form as Form
import User.SessionData as Session exposing (Session)
import User.UserData exposing (User)
import Project.RepositoryData exposing (Repository)
import Project.FileData exposing (File)
import Project.RepositoryRequest as RepositoryRequest
import Helpers.Request.ErrorsData as ErrorsData
import Util exposing ((=>))
import Route
import Helpers.Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import View


type alias Model =
    { errors : List ( String, String )
    , name : String
    , namespace : String
    , privacy : String
    , fileList : Maybe (List File)
    }


type MsgShow
    = RepositoryLoadedFiles (Result Http.Error (List File))


type Msg
    = SetRepositoryName String
    | SetPrivacy PrivacyType
    | SubmitForm
    | RepositoryCreated (Result Http.Error Repository)


type ExternalMsg
    = NoOp


type PrivacyType
    = Public
    | Private


initNew : Model
initNew =
    { errors = []
    , name = ""
    , namespace = ""
    , privacy = "private"
    , fileList = Nothing
    }


initShow : String -> String -> Session -> Task PageLoadError Model
initShow namespace repo session =
    let
        authToken =
            Session.maybeAuthToken session

        handleLoadError _ =
            pageLoadError View.Other "Repository is currently unavailable."
    in
        RepositoryRequest.get namespace repo authToken
            |> Http.toTask
            |> Task.mapError handleLoadError
            |> Task.map
                (\repo ->
                    { errors = []
                    , name = repo.name
                    , namespace = repo.namespace
                    , privacy = repo.privacy
                    , fileList = Nothing
                    }
                )


listFiles : Model -> Session -> Cmd MsgShow
listFiles repo session =
    let
        authToken =
            Session.maybeAuthToken session
    in
        RepositoryRequest.listFiles repo authToken
            |> Http.send RepositoryLoadedFiles


viewShow : Session -> Model -> Html MsgShow
viewShow session model =
    div [ class "repo-first-page" ]
        [ h1 [ class "text-xs-center" ]
            [ text ("Show Repo " ++ model.name)
            ]
        , div [] (viewListFiles model)
        ]


viewListFiles : Model -> List (Html MsgShow)
viewListFiles model =
    case model.fileList of
        Just fileList ->
            (List.map (\file -> div [] [ text file.name ]) fileList)

        Nothing ->
            [ div [] [ text "loading..." ] ]


updateShow : Session -> MsgShow -> Model -> ( Model, Cmd MsgShow )
updateShow session msg model =
    case msg of
        RepositoryLoadedFiles (Ok fileList) ->
            { model | fileList = Just fileList }
                => Cmd.none

        _ ->
            model
                => Cmd.none


view : Session -> Model -> Html Msg
view session model =
    case session.user of
        Just user ->
            viewNewReo user model

        Nothing ->
            div [ class "repo-page" ]
                []


viewNewReo : User -> Model -> Html Msg
viewNewReo user model =
    div [ class "repo-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                    [ h1 [ class "text-xs-center" ] [ text "Create Repo" ]
                    , Form.viewErrors model.errors
                    , viewForm user
                    ]
                ]
            ]
        ]


viewForm : User -> Html Msg
viewForm user =
    Html.form [ onSubmit SubmitForm ]
        [ Form.select [ class "form-control-lg" ] (allowedRepoSubNameOptions user)
        , Form.input
            [ class "form-control-lg"
            , placeholder "Repository name"
            , onInput SetRepositoryName
            ]
            []
        , Form.fieldset [ class "form-control-lg" ]
            [ label []
                [ Form.radio
                    [ onClick (SetPrivacy Private)
                    , name "privacyPicker"
                    , checked True
                    ]
                    []
                , text "Private"
                ]
            , label []
                [ Form.radio
                    [ onClick (SetPrivacy Public)
                    , name "privacyPicker"
                    ]
                    []
                , text "Public"
                ]
            ]
        , button [ class "btn btn-lg btn-primary pull-xs-right" ]
            [ text "Create repository" ]
        ]


allowedRepoSubNameOptions : User -> List (Html Msg)
allowedRepoSubNameOptions user =
    (List.map (\un -> option [ onClick (SetRepositoryName un) ] [ text un ]) [ user.username ])


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case Debug.log "msg: " msg of
        SetRepositoryName repo_name ->
            { model | name = repo_name }
                => Cmd.none

        SetPrivacy privacy ->
            let
                privacy_text =
                    case privacy of
                        Private ->
                            "private"

                        Public ->
                            "public"
            in
                { model | privacy = privacy_text }
                    => Cmd.none

        SubmitForm ->
            let
                newModule =
                    { model | namespace = getSessionUsername (session) }

                authToken =
                    Session.maybeAuthToken session

                cmdToCreateRepo =
                    RepositoryRequest.new newModule authToken
                        |> Http.send RepositoryCreated
            in
                { newModule | errors = [] }
                    => cmdToCreateRepo

        RepositoryCreated (Err error) ->
            let
                errorMessages =
                    ErrorsData.httpErrorToList "repository creation" error errorsDecoder
            in
                { model | errors = List.map (\errorMessage -> "Form" => errorMessage) errorMessages }
                    => Cmd.none

        RepositoryCreated (Ok repo) ->
            model
                => Cmd.batch [ Route.modifyUrl (Route.ShowRepository repo.namespace repo.name) ]


errorsDecoder : Decoder (List String)
errorsDecoder =
    decode (\name privacy -> List.concat [ name, privacy ])
        |> ErrorsData.optionalError "name"
        |> ErrorsData.optionalError "privacy"


getSessionUsername : Session -> String
getSessionUsername session =
    case session.user of
        Just user ->
            user.username

        Nothing ->
            ""
