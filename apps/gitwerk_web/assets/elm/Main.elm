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
import Helpers.Ports as Ports
import Util exposing ((=>))
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
    | SetUser (Maybe User)


initialPage : Page
initialPage =
    Blank


view : Model -> Html.Html Msg
view model =
    case model.pageState of
        Loaded page ->
            viewPage model.session False page

        TransitioningFrom page ->
            viewPage model.session True page


viewPage : Session -> Bool -> Page -> Html.Html Msg
viewPage session isLoading page =
    let
        frame =
            View.frame isLoading session.user
    in
        case page of
            NotFound ->
                Html.text "Not Found"

            Blank ->
                Html.text "Blank"

            Login subModel ->
                User.LoginPage.view session subModel
                    |> frame View.Login
                    |> Html.map LoginMsg

            Join subModel ->
                User.SignupPage.view subModel
                    |> frame View.Join
                    |> Html.map JoinMsg

            Home subModel ->
                Home.MainPage.view session subModel
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
        session =
            model.session

        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate subMsg subModel
            in
                ( { model | pageState = Loaded (toModel newModel) }, Cmd.map toMsg newCmd )
    in
        case ( msg, page ) of
            ( SetRoute route, _ ) ->
                setRoute route model

            ( LoginMsg subMsg, Login subModel ) ->
                let
                    ( ( pageModel, cmd ), msgFromPage ) =
                        User.LoginPage.update subMsg subModel

                    newModel =
                        case msgFromPage of
                            User.LoginPage.NoOp ->
                                model

                            User.LoginPage.SetUser user ->
                                let
                                    session =
                                        model.session
                                in
                                    { model | session = { user = Just user } }
                in
                    { newModel | pageState = Loaded (Login pageModel) }
                        => Cmd.map LoginMsg cmd

            ( JoinMsg subMsg, Join subModel ) ->
                let
                    ( ( pageModel, cmd ), msgFromPage ) =
                        User.SignupPage.update subMsg subModel

                    newModel =
                        case msgFromPage of
                            User.SignupPage.NoOp ->
                                model

                            User.SignupPage.SetUser user ->
                                let
                                    session =
                                        model.session
                                in
                                    { model | session = { user = Just user } }
                in
                    ( { newModel | pageState = Loaded (Join pageModel) }, Cmd.map JoinMsg cmd )

            ( _, _ ) ->
                Debug.log "unhandled event" ( model, Cmd.none )


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition toMsg task =
            ( { model | pageState = TransitioningFrom (getPage model.pageState) }, Task.attempt toMsg task )
    in
        case maybeRoute of
            Nothing ->
                ( { model | pageState = Loaded NotFound }, Cmd.none )

            Just (Route.Home) ->
                ( { model | pageState = Loaded (Home Home.MainPage.initialModel) }, Cmd.none )

            Just (Route.Login) ->
                ( { model | pageState = Loaded (Login User.LoginPage.initialModel) }, Cmd.none )

            Just (Route.Join) ->
                ( { model | pageState = Loaded (Join User.SignupPage.initialModel) }, Cmd.none )

            Just (Route.Logout) ->
                let
                    session =
                        model.session
                in
                    { model | session = { session | user = Nothing } }
                        => Cmd.batch
                            [ Ports.storeSession Nothing
                            , Route.modifyUrl Route.Login
                            ]

            Just (Route.NewRepository) ->
                model
                    => Cmd.none


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ pageSubscriptions (getPage model.pageState)
        , Sub.map SetUser sessionChange
        ]


sessionChange : Sub (Maybe User)
sessionChange =
    Ports.onSessionChange (Decode.decodeValue User.decoder >> Result.toMaybe)


pageSubscriptions : Page -> Sub Msg
pageSubscriptions page =
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
