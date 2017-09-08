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
    , email : String
    , password : String
    , mdl : Material.Model
    }


type Msg
    = Mdl (Material.Msg Msg)
    | SetEmail String
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
    , mdl = Material.model
    }


view : Model -> Html Msg
view model =
    div []
        [ grid []
            [ cell [ Grid.size Phone 4, Grid.size Tablet 6, offset Tablet 1, Grid.size Desktop 8, offset Desktop 2 ]
                [ h4 [] [ text "Join GitWerk" ]
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
                    , div
                        []
                        [ Textfield.render Mdl
                            [ 1 ]
                            model.mdl
                            [ Textfield.label "Email"
                            , Textfield.floatingLabel
                            , Textfield.text_
                            , Form.textfieldShowErrorIfAny "email" model.errors
                            , Options.onInput SetEmail
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
                            [ text "Sign up" ]
                        ]
                    , Options.styled div
                        [ Typo.body1 ]
                        [ a [ Route.href Route.Login ] [ text "Have an account?" ]
                        ]
                    ]
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

        Mdl msg_ ->
            Material.update Mdl msg_ model
                => NoOp


errorsDecoder : Decoder (List ( String, List String ))
errorsDecoder =
    decode (\email username password -> List.concat [ [ ( "email", email ) ], [ ( "username", username ) ], [ ( "password", password ) ] ])
        |> ErrorsData.optionalError "email"
        |> ErrorsData.optionalError "username"
        |> ErrorsData.optionalError "password"
