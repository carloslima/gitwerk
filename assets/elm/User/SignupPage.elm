module User.SignupPage exposing (..)

import Http
import Util exposing ((=>))
import Html.Events exposing (onInput, onSubmit)
import Html
import Html exposing (..)
import Html.Attributes exposing (..)
import Html exposing (Html, Attribute, div, input, text)
import Json.Decode as Decode exposing (Decoder, decodeString, field, string)
import Json.Decode.Pipeline as Pipeline exposing (decode, optional)
import Helpers.Views.Form as Form
import Route
import User.UserData as User exposing (User)
import User.UserRequest as UserRequest
import Helpers.Request.ErrorsData as ErrorsData
import Debug


type alias Model =
    { errors : List (String, String)
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
    { errors = []
    , username = ""
    , email = ""
    , password = ""
    }


view : Model -> Html.Html Msg
view model =
    div [ class "auth-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                    [ h1 [ class "text-xs-center" ] [ text "Join" ]
                    , p [ class "text-xs-center" ]
                        [ a [ Route.href Route.Login ]
                            [ text "Have an account?" ]
                        ]
                    , Form.viewErrors model.errors
                    , viewForm
                    ]
                ]
            ]
        ]


viewForm : Html Msg
viewForm =
    Html.form [ onSubmit SubmitForm ]
        [ Form.input
            [ class "form-control-lg"
            , placeholder "Username"
            , onInput SetUsername
            ]
            []
        , Form.input
            [ class "form-control-lg"
            , placeholder "Email"
            , onInput SetEmail
            ]
            []
        , Form.password
            [ class "form-control-lg"
            , placeholder "Password"
            , onInput SetPassword
            ]
            []
        , button [ class "btn btn-lg btn-primary pull-xs-right" ]
            [ text "Sign up" ]
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
            { model | errors = [] }
                => Http.send RegisterCompleted (UserRequest.register model)
                => NoOp

        RegisterCompleted (Err error) ->
            let
                errorMessages = ErrorsData.httpErrorToList "registration" error errorsDecoder
            in
                { model | errors = List.map (\errorMessage -> "Form" => errorMessage) errorMessages }
                    => Cmd.none
                    => NoOp

        RegisterCompleted (Ok user) ->
            model
            => Cmd.batch [UserRequest.storeSession user, Route.modifyUrl Route.Home]
            => SetUser user

errorsDecoder : Decoder (List String)
errorsDecoder =
    decode (\email username password -> List.concat [ email, username, password ])
        |> ErrorsData.optionalError "email"
        |> ErrorsData.optionalError "username"
        |> ErrorsData.optionalError "password"
