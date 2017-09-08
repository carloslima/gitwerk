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


-- Material

import Material.Grid as Grid exposing (align, offset, grid, cell, Device(..))
import Material.Options as Options exposing (cs, css, Style, when)
import Material.Elevation as Elevation
import Material.Button as Button
import Material.Typography as Typo
import Material
import Material.Textfield as Textfield


type alias Model =
    { errors : Dict String (List String)
    , username : String
    , password : String
    , mdl : Material.Model
    }


initialModel : Model
initialModel =
    { errors = Dict.empty
    , username = ""
    , password = ""
    , mdl = Material.model
    }


type Field
    = Form
    | Username
    | Password


type Msg
    = Mdl (Material.Msg Msg)
    | SetUsername String
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
        [ grid []
            [ cell [ Grid.size Phone 4, Grid.size Tablet 6, offset Tablet 1, Grid.size Desktop 8, offset Desktop 2 ]
                [ h4 [] [ text "Sign in to GitWerk" ]
                ]
            ]
        , Options.div
            [ Elevation.e4
            , Options.center
            , css "width" "408px"
            , css "margin" "auto"
            ]
            [ viewForm (model)
            ]
        ]


viewForm : Model -> Html Msg
viewForm model =
    let
        general_err =
            Form.anyDefaultError "default_error" model.errors
    in
        Html.form [ onSubmit SubmitForm ]
            [ grid
                []
                [ cell [ Grid.size All 12 ]
                    [ Options.styled div
                        [ css "color" "red"
                        , Typo.center
                        , Typo.body2
                        ]
                        [ text (Maybe.withDefault "" general_err) ]
                    , div
                        []
                        [ Textfield.render Mdl
                            [ 0 ]
                            model.mdl
                            [ Textfield.label "username"
                            , Textfield.floatingLabel
                            , Textfield.text_
                            , Form.textfieldShowErrorIfAny "username" model.errors
                            , Options.onInput SetUsername
                            ]
                            []
                        ]
                    , div []
                        [ Textfield.render Mdl
                            [ 2 ]
                            model.mdl
                            [ Textfield.label "Password"
                            , Textfield.floatingLabel
                            , Textfield.password
                            , Options.onInput SetPassword
                            , Form.textfieldShowErrorIfAny "password" model.errors
                            ]
                            []
                        ]
                    , div []
                        [ Button.render Mdl
                            [ 3 ]
                            model.mdl
                            [ Button.raised
                            , Button.ripple
                            , Button.colored
                            , Options.onClick SubmitForm
                            ]
                            [ text "Sign in" ]
                        ]
                    , Options.styled div
                        [ Typo.body1 ]
                        [ text "or "
                        , a [ Route.href Route.Join ] [ text "create an account" ]
                        ]
                    ]
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

        Mdl msg_ ->
            Material.update Mdl msg_ model
                => NoOp


errorsDecoder : Decoder (List ( String, List String ))
errorsDecoder =
    decode (\username password -> List.concat [ [ ( "username", username ) ], [ ( "password", password ) ] ])
        |> ErrorsData.optionalError "username"
        |> ErrorsData.optionalError "password"
