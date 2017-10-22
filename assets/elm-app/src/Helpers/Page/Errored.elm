module Helpers.Page.Errored exposing (PageLoadError, pageLoadError, view)

import Html exposing (Html, div, h1, img, main_, p, text)
import Html.Attributes exposing (alt, class, id, tabindex)
import User.SessionData as Session exposing (Session)
import View exposing (ActivePage)


-- MODEL --


type PageLoadError
    = PageLoadError Model


type alias Model =
    { activePage : ActivePage
    , errorMessage : String
    }


pageLoadError : ActivePage -> String -> PageLoadError
pageLoadError activePage errorMessage =
    PageLoadError { activePage = activePage, errorMessage = errorMessage }



-- VIEW --


view : Session -> PageLoadError -> Html msg
view session (PageLoadError model) =
    main_ [ id "content", class "container", tabindex -1 ]
        [ h1 [] [ text "Error Loading Page" ]
        , div [ class "row" ]
            [ p [] [ text model.errorMessage ] ]
        ]
