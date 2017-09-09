module User.LoginPage exposing (ExternalMsg(..), initialModel, Model, view, Msg, update)

import Html
import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, optional)
import Helpers.Views.Form as Form
import User.SessionData exposing (Session)
import User.UserData exposing (User)
import User.UserRequest as UserRequest
import Util exposing ((=>))
import Helpers.Request.ErrorsData as ErrorsData
import Route
import Dict exposing (Dict)


-- Bootstrap

import Bootstrap.Form as BForm
import Bootstrap.Form.Input as BInput
import Bootstrap.Form.Fieldset as BFieldset
import Bootstrap.Button as BButton
import Bootstrap.Alert as BAlert
import Bootstrap.Grid as BGrid
import Bootstrap.Grid.Row as BRow
import Bootstrap.Grid.Col as BCol


type alias Model =
    { errors : Dict String (List String)
    , username : String
    , password : String
    }


initialModel : Model
initialModel =
    { errors = Dict.empty
    , username = ""
    , password = ""
    }


type Field
    = Form
    | Username
    | Password


type Msg
    = SetUsername String
    | SetPassword String
    | SubmitForm
    | LoginCompleted (Result Http.Error User)


type alias Error =
    ( Field, String )


type ExternalMsg
    = NoOp
    | SetUser User



-- VIEW --


view : Session -> Model -> Html Msg
view session model =
    div []
        [ h4 [] [ text "Sign in to GitWerk" ]
        , BGrid.row [ BRow.middleXs ]
            [ BGrid.col [ BCol.md6, BCol.offsetMd3 ]
                [ div
                    [ style
                        [ "margin" => "auto"
                        , "width" => "408px"
                        , "border" => "solid #f7f7f9"
                        , "border-width" => ".2rem"
                        , "padding" => "50px"
                        ]
                    ]
                    [ viewForm (model)
                    ]
                ]
            ]
        ]


viewForm : Model -> Html Msg
viewForm model =
    let
        groupOption field errors =
            case Form.getErrorFor field errors of
                Nothing ->
                    []

                Just _ ->
                    [ BForm.groupDanger ]
    in
        BForm.form [ onSubmit SubmitForm ]
            [ div []
                [ Form.showDefaultErrorIfAny (model.errors) ]
            , BForm.group (groupOption "username" model.errors)
                [ BForm.label [ for "username" ] [ text "Username or Email" ]
                , BInput.text
                    [ BInput.id "username"
                    , BInput.onInput SetUsername
                    ]
                , Form.validationTextIfAny "username" model.errors
                ]
            , BForm.group []
                [ BForm.label [ for "password" ] [ text "Password" ]
                , BInput.password
                    [ BInput.id "password"
                    , BInput.onInput SetPassword
                    ]
                ]
            , BButton.button [ BButton.primary ] [ text "Sign in" ]
            , div []
                [ text "or "
                , a [ Route.href Route.Join ] [ text "create an account" ]
                ]
            ]


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        SetUsername username ->
            { model | username = username }
                => Cmd.none
                => NoOp

        SetPassword password ->
            { model | password = password }
                => Cmd.none
                => NoOp

        SubmitForm ->
            { model | errors = Dict.empty }
                => Http.send LoginCompleted (UserRequest.login model)
                => NoOp

        LoginCompleted (Err error) ->
            let
                errorMessages =
                    ErrorsData.httpErrorToList2 "login" error errorsDecoder
            in
                { model | errors = errorMessages }
                    => Cmd.none
                    => NoOp

        LoginCompleted (Ok user) ->
            model
                => Cmd.batch [ UserRequest.storeSession user, Route.modifyUrl Route.Home ]
                => SetUser user


errorsDecoder : Decoder (List ( String, List String ))
errorsDecoder =
    decode (\username password -> List.concat [ [ ( "username", username ) ], [ ( "password", password ) ] ])
        |> ErrorsData.optionalError "username"
        |> ErrorsData.optionalError "password"
