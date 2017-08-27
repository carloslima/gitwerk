module Main exposing (main)

import Navigation exposing (Location)
import Route exposing (Route)
import Json.Decode as Decode exposing (Value)
import Html
import Task
import User.LoginPage
import User.SignupPage
import Home.MainPage
import Project.RepositoryPage
import Project.RepositoryData exposing (Repository)
import User.SessionData exposing (Session)
import User.UserData as User exposing (User)
import Helpers.Ports as Ports
import Util exposing ((=>))
import Debug
import View
import Helpers.Page.Errored as Errored exposing (PageLoadError)


type Page
    = Blank
    | NotFound
    | Errored PageLoadError
    | Login User.LoginPage.Model
    | Join User.SignupPage.Model
    | Home Home.MainPage.Model
    | Project Project.RepositoryPage.Model
    | ShowRepository Project.RepositoryPage.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page


type alias Model =
    { pageState : PageState
    , session : Session
    }


type Msg
    = SetRoute (Maybe Route)
    | LoginMsg User.LoginPage.Msg
    | JoinMsg User.SignupPage.Msg
    | HomeMsg Home.MainPage.Msg
    | ProjectMsg Project.RepositoryPage.Msg
    | ProjectCodeMsg Project.RepositoryPage.MsgShow
    | RepositoryLoaded String String (Result PageLoadError Project.RepositoryPage.Model)
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
                Html.text ""
                    |> frame View.Other

            Errored subModel ->
                Errored.view session subModel
                    |> frame View.Other

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

            Project subModel ->
                Project.RepositoryPage.view session subModel
                    |> frame View.Home
                    |> Html.map ProjectMsg

            ShowRepository subModel ->
                Project.RepositoryPage.viewShow session subModel
                    |> frame View.Home
                    |> Html.map ProjectCodeMsg


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

            ( RepositoryLoaded namespace repo_name (Ok subModel), _ ) ->
                { model | pageState = Loaded (ShowRepository subModel) }
                    => Cmd.map ProjectCodeMsg (Project.RepositoryPage.listFiles subModel session)

            ( RepositoryLoaded _ _ (Err error), _ ) ->
                { model | pageState = Loaded (Errored error) } => Cmd.none

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

            ( ProjectMsg subMsg, Project subModel ) ->
                toPage Project ProjectMsg (Project.RepositoryPage.update model.session) subMsg subModel

            ( ProjectCodeMsg subMsg, ShowRepository subModel ) ->
                toPage ShowRepository ProjectCodeMsg (Project.RepositoryPage.updateShow model.session) subMsg subModel

            ( subMsg, subModel ) ->
                let
                    _ =
                        Debug.log "subMsg: " subMsg

                    _ =
                        Debug.log "subModel: " subModel
                in
                    Debug.log "unhandled event" ( model, Cmd.none )


pageErrored : Model -> View.ActivePage -> String -> ( Model, Cmd msg )
pageErrored model activePage errorMessage =
    let
        error =
            Errored.pageLoadError activePage errorMessage
    in
        { model | pageState = Loaded (Errored error) } => Cmd.none


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition toMsg task =
            { model | pageState = TransitioningFrom (getPage model.pageState) }
                => Task.attempt toMsg task

        errored =
            pageErrored model
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
                { model | pageState = Loaded (Project Project.RepositoryPage.initNew) }
                    => Cmd.none

            Just (Route.ShowRepository namespace repo) ->
                transition (RepositoryLoaded namespace repo) (Project.RepositoryPage.initShow namespace repo model.session)


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
