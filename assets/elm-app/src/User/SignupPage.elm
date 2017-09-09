module User.SignupPage exposing (..)

import Http
import Util exposing ((=>))
import Html.Events exposing (onInput, onSubmit)
import Html
import Html exposing (..)
import Html.Attributes exposing (..)
import Html exposing (Html, div, text)
import Json.Decode as Decode exposing (Decoder, decodeString, field, string)
import Json.Decode.Pipeline as Pipeline exposing (decode, optional)
import Helpers.Views.Form as Form
import Route
import User.UserData as User exposing (User)
import User.UserRequest as UserRequest
import Helpers.Request.ErrorsData as ErrorsData
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
    , email : String
    , password : String
    }


type Msg
    = SetEmail String
    | SetPassword String
    | SetUsername String
    | SubmitForm
    | RegisterCompleted (Result Http.Error User)


type Field
    = Form
    | Username
    | Email
    | Password


type alias Error =
    ( Field, String )


type ExternalMsg
    = NoOp
    | SetUser User


initialModel : Model
initialModel =
    { errors = Dict.empty
    , username = ""
    , email = ""
    , password = ""
    }


view : Model -> Html Msg
view model =
    div
        [ class "jumbotron"
        , style
            [ "background" => "transparent" ]
        ]
        [ h4 [] [ text "Join GitWerk" ]
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
                [ BForm.label [ for "username" ] [ text "Username" ]
                , BInput.text
                    [ BInput.id "username"
                    , BInput.onInput SetUsername
                    ]
                , Form.validationTextIfAny "username" model.errors
                ]
            , BForm.group (groupOption "email" model.errors)
                [ BForm.label [ for "email" ] [ text "Email" ]
                , BInput.text
                    [ BInput.id "email"
                    , BInput.onInput SetEmail
                    ]
                , Form.validationTextIfAny "email" model.errors
                ]
            , BForm.group (groupOption "password" model.errors)
                [ BForm.label [ for "password" ] [ text "Password" ]
                , BInput.password
                    [ BInput.id "password"
                    , BInput.onInput SetPassword
                    ]
                , Form.validationTextIfAny "password" model.errors
                ]
            , BButton.button [ BButton.primary ] [ text "Sign Up" ]
            , div []
                [ text "or "
                , a [ Route.href Route.Login ] [ text "Have an account?" ]
                ]
            ]


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        SetEmail email ->
            { model | email = email }
                => Cmd.none
                => NoOp

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
                => Http.send RegisterCompleted (UserRequest.register model)
                => NoOp

        RegisterCompleted (Err error) ->
            let
                errorMessages =
                    ErrorsData.httpErrorToList2 "registration" error errorsDecoder
            in
                { model | errors = errorMessages }
                    => Cmd.none
                    => NoOp

        RegisterCompleted (Ok user) ->
            model
                => Cmd.batch [ UserRequest.storeSession user, Route.modifyUrl Route.Home ]
                => SetUser user


errorsDecoder : Decoder (List ( String, List String ))
errorsDecoder =
    decode (\email username password -> List.concat [ [ ( "email", email ) ], [ ( "username", username ) ], [ ( "password", password ) ] ])
        |> ErrorsData.optionalError "email"
        |> ErrorsData.optionalError "username"
        |> ErrorsData.optionalError "password"
