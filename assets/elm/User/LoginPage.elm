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


type alias Model =
    { errors : List Error
    , username : String
    , password : String
    }


initialModel : Model
initialModel =
    { errors = []
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
    div [ class "auth-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                    [ h1 [ class "text-xs-center" ] [ text "Login" ]
                    , p [ class "text-xs-center" ]
                        [ a [ Route.href Route.Join ]
                            [ text "Need an account?" ]
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
        , Form.password
            [ class "form-control-lg"
            , placeholder "Password"
            , onInput SetPassword
            ]
            []
        , button [ class "btn btn-lg btn-primary pull-xs-right" ]
            [ text "Sign in" ]
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
            { model | errors = [] }
                => Http.send LoginCompleted (UserRequest.login model)
                => NoOp

        LoginCompleted (Err error) ->
            let
                errorMessages = ErrorsData.httpErrorToList "registration" error errorsDecoder
            in
                { model | errors = List.map (\errorMessage -> Form => errorMessage) errorMessages }
                    => Cmd.none
                    => NoOp

        LoginCompleted (Ok user) ->
            model
            => Cmd.batch [UserRequest.storeSession user, Route.modifyUrl Route.Home]
            => SetUser user

errorsDecoder : Decoder (List String)
errorsDecoder =
    decode (\username password -> List.concat [ username, password ])
        |> ErrorsData.optionalError "username"
        |> ErrorsData.optionalError "password"

