module Main exposing (main)

import Navigation exposing (Location)
import Route exposing (Route)
import Json.Decode as Decode exposing (Value)
import Html
import Task
import User.LoginPage
import User.SignupPage
import Home.MainPage
import User.SessionData exposing (Session)
import User.UserData as User exposing (User)
import Debug
import View


type Page
    = Blank
    | NotFound
    | Login User.LoginPage.Model
    | Join User.SignupPage.Model
    | Home Home.MainPage.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page


type alias Model =
    { pageState : PageState
    , session : Session
    }


type PageLoadError
    = PageLoadError Model


type Msg
    = SetRoute (Maybe Route)
    | LoginMsg User.LoginPage.Msg
    | JoinMsg User.SignupPage.Msg
    | HomeMsg Home.MainPage.Msg


initialPage : Page
initialPage =
    Blank


view : Model -> Html.Html Msg
view model =
    case model.pageState of
        Loaded page ->
            viewPage page

        TransitioningFrom page ->
            viewPage page


viewPage : Page -> Html.Html Msg
viewPage page =
    let
        frame =
            View.frame
    in
        case page of
            NotFound ->
                Html.text "Not Found"

            Blank ->
                Html.text "Blank"

            Login subModel ->
                User.LoginPage.view subModel
                    |> frame View.Login
                    |> Html.map LoginMsg

            Join subModel ->
                User.SignupPage.view subModel
                    |> frame View.Join
                    |> Html.map JoinMsg

            Home subModel ->
                Home.MainPage.view subModel
                    |> frame View.Home
                    |> Html.map HomeMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updatePage (getPage model.pageState) msg model


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page


updatePage : Page -> Msg -> Model -> ( Model, Cmd Msg )
updatePage page msg model =
    let
        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate subMsg subModel
            in
                ( { model | pageState = Loaded (toModel newModel) }, Cmd.map toMsg newCmd )
    in
        case Debug.log" updatePage: " ( msg, page ) of
            ( SetRoute route, _ ) ->
                setRoute route model

            ( LoginMsg subMsg, Login subModel ) ->
                let
                    ( ( pageModel, cmd ), msgFromPage ) =
                        User.LoginPage.update subMsg subModel

                    newModel =
                        model
                in
                    ( { newModel | pageState = Loaded (Login pageModel) }, Cmd.map LoginMsg cmd )

            ( _, _ ) ->
                ( model, Cmd.none )


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition toMsg task =
            ( { model | pageState = TransitioningFrom (getPage model.pageState) }, Task.attempt toMsg task )
    in
        case Debug.log "setRoute: " maybeRoute of
            Nothing ->
                ( { model | pageState = Loaded NotFound }, Cmd.none )

            Just (Route.Home) ->
                ( { model | pageState = Loaded (Home Home.MainPage.initialModel) }, Cmd.none )

            Just (Route.Login) ->
                ( { model | pageState = Loaded (Login User.LoginPage.initialModel) }, Cmd.none )

            Just (Route.Join) ->
                ( { model | pageState = Loaded (Join User.SignupPage.initialModel) }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : Value -> Location -> ( Model, Cmd Msg )
init val location =
    setRoute (Route.fromLocation location)
        { pageState = Loaded initialPage
        , session = { user = User.decodeUserFromJson val }
        }


main : Program Value Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
