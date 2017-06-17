module User.LoginPage exposing (initialModel, Model, view, Msg, update)

import Html


type alias Model =
    { errors : List String
    , email : String
    , password : String
    }


initialModel : Model
initialModel =
    { errors = []
    , email = ""
    , password = ""
    }


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.text "Login Page"
        ]


type Msg
    = SetEmail String


type ExternalMsg
    = NoOp


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        SetEmail email ->
            ( ( { model | email = email }, Cmd.none ), NoOp )
