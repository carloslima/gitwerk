module Project.View exposing (..)

import Html
import Html exposing (..)
import Html.Attributes exposing (..)
import Util exposing ((=>))
import Octicons
import Route


projectHeader : { r | namespace : String, name : String } -> Html msg
projectHeader { namespace, name } =
    div [ class "page-head project-head" ]
        [ div [ class "container project-head-details-container" ]
            [ h1 []
                [ span [] [ Octicons.defaultOptions |> Octicons.size 16 |> Octicons.repo ]
                , span [] [ strong [] [ a [ href ("#" ++ namespace) ] [ text namespace ] ] ]
                , span [ style [ "margin" => "0 0.25em" ] ] [ text "/" ]
                , span []
                    [ strong []
                        [ a [ Route.href (Route.ShowRepository namespace name) ]
                            [ text name ]
                        ]
                    ]
                ]
            ]
        , text "Header"
        ]
