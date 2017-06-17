module Home.MainPage exposing (initialModel, Model, view, Msg, update)

import Html exposing (..)
import Route


type alias Model =
    {}


initialModel : Model
initialModel =
    {}


view : Model -> Html.Html Msg
view model =
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
