module Project.RepositoryPage exposing (..)

import Html
import Http
import Html exposing (..)
import Html.Attributes exposing (..)


type alias Model =
    { errors : List String
    , repository_name : String
    }


type Msg
    = NoOp


initNew : Model
initNew =
    { errors = []
    , repository_name = ""
    }


view : Model -> Html Msg
view model =
    div [ class "repo-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                    [ h1 [ class "text-xs-center" ] [ text "Create Repo" ]
                    ]
                ]
            ]
        ]

