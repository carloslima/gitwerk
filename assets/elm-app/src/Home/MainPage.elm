module Home.MainPage exposing (initialModel, Model, view, Msg, update)

import Html exposing (..)
import Route
import User.SessionData exposing (Session)


type alias Model =
    {}


initialModel : Model
initialModel =
    {}


view : Session -> Model -> Html.Html Msg
view user model =
    Html.div []
        [ Html.text "Home Page"
        ]


type Msg
    = NoOp1


type ExternalMsg
    = NoOp2


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        NoOp1 ->
            ( ( model, Cmd.none ), NoOp2 )
