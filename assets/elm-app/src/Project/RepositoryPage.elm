module Project.RepositoryPage exposing (..)

import Html
import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit, onClick)
import Debug
import Task exposing (Task)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, optional)
import Helpers.Views.Form as Form
import User.SessionData as Session exposing (Session)
import User.UserData exposing (User)
import Project.RepositoryData exposing (Repository)
import Project.FileData exposing (File)
import Project.RepositoryRequest as RepositoryRequest
import Project.View as ProjectView
import Helpers.Request.ErrorsData as ErrorsData
import Util exposing ((=>))
import Route
import Helpers.Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import View
import Gravatar
import Octicons


type alias Model =
    { errors : List ( String, String )
    , name : String
    , namespace : String
    , privacy : String
    , fileList : Maybe (List File)
    , cwd : List String
    , tree : String
    }


type MsgShow
    = RepositoryLoadedFiles (Result Http.Error (List File))
    | LoadRepositoryTree String (List String)


type Msg
    = SetRepositoryName String
    | SetPrivacy PrivacyType
    | SubmitForm
    | SetNamespace String
    | RepositoryCreated (Result Http.Error Repository)


type ExternalMsg
    = NoOp


type PrivacyType
    = Public
    | Private


initNew : Model
initNew =
    { errors = []
    , name = ""
    , namespace = ""
    , privacy = "private"
    , fileList = Nothing
    , cwd = []
    , tree = ""
    }


initShow : String -> String -> String -> List String -> Session -> Task PageLoadError Model
initShow namespace repo tree cwd session =
    let
        authToken =
            Session.maybeAuthToken session

        handleLoadError _ =
            pageLoadError View.Other "Repository is currently unavailable."
    in
        RepositoryRequest.get namespace repo authToken
            |> Http.toTask
            |> Task.mapError handleLoadError
            |> Task.map
                (\repo ->
                    { errors = []
                    , name = repo.name
                    , namespace = repo.namespace
                    , privacy = repo.privacy
                    , fileList = Nothing
                    , cwd = cwd
                    , tree = tree
                    }
                )


listFiles : Model -> Session -> List String -> Cmd MsgShow
listFiles model session filePath =
    let
        authToken =
            Session.maybeAuthToken session
    in
        RepositoryRequest.listFiles model filePath authToken
            |> Http.send RepositoryLoadedFiles


inPageReload : Model -> Session -> Cmd MsgShow
inPageReload model session =
    listFiles model session model.cwd


viewShow : Session -> Model -> Html MsgShow
viewShow session model =
    div [ class "repo-page" ]
        [ ProjectView.projectHeader model
        , h1 [ class "text-xs-center" ]
            [ text (model.namespace ++ "/" ++ model.name)
            ]
        , div [] (viewListFiles model)
        ]


viewListFiles : Model -> List (Html MsgShow)
viewListFiles model =
    let
        fileListError =
            model.errors
                |> List.filter (\( title, _ ) -> title == "FileList")
                |> List.map (\( _, msg ) -> msg)
                |> List.head
    in
        case fileListError of
            Nothing ->
                case model.fileList of
                    Just fileList ->
                        (List.map (\file -> div [] [ viewListFilesLinks model file ]) fileList)

                    Nothing ->
                        [ div [] [ text "loading..." ] ]

            Just errorMessage ->
                [ div [] [ text (errorMessage ++ " :(") ] ]


viewListFilesLinks : Model -> File -> Html MsgShow
viewListFilesLinks model file =
    div [] [ a [ Route.href (Route.ShowRepositoryTree model.namespace model.name model.tree (getCwd model file)) ] [ text file.name ] ]


getCwd : Model -> File -> List String
getCwd model file =
    case model.cwd of
        [] ->
            [ file.name ]

        cwd ->
            List.append cwd [ file.name ]


internalLoadRepo : Session -> Model -> String -> List String -> ( Model, Cmd MsgShow )
internalLoadRepo session model tree path =
    let
        msg =
            LoadRepositoryTree tree path
    in
        updateShow session msg model


updateShow : Session -> MsgShow -> Model -> ( Model, Cmd MsgShow )
updateShow session msg model =
    case msg of
        RepositoryLoadedFiles (Ok fileList) ->
            { model | fileList = Just fileList }
                => Cmd.none

        RepositoryLoadedFiles (Err error) ->
            let
                _ =
                    Debug.log "error " error
            in
                { model | errors = [ "FileList" => "failed to fetch file list" ] }
                    => Cmd.none

        LoadRepositoryTree tree path ->
            model
                => listFiles model session path


view : Session -> Model -> Html Msg
view session model =
    case session.user of
        Just user ->
            viewNewReo user model

        Nothing ->
            div [ class "repo-page" ]
                []


viewNewReo : User -> Model -> Html Msg
viewNewReo user model =
    div
        [ class "new-repo-page"
        , style
            [ "width" => "700px"
            , "margin" => "40px auto 0"
            ]
        ]
        [ div [ class "row" ]
            [ div [ class "col-12 text-left" ]
                [ div [ class "subhead" ]
                    [ h2 [ class "subhead-heading" ] [ text "Create a new repository" ]
                    , p [ class "subhead-description" ]
                        [ text "A repository contains all the files for your project, including the revision history."
                        ]
                    ]
                , Form.viewErrors model.errors
                , viewForm model user
                ]
            ]
        ]


gravatarHeaderOption : Gravatar.Options
gravatarHeaderOption =
    Gravatar.defaultOptions
        |> Gravatar.withSize (Just 30)
        |> Gravatar.withDefault Gravatar.Retro


viewForm : Model -> User -> Html Msg
viewForm model user =
    Html.form [ onSubmit SubmitForm ]
        [ table [ class "new-repo-table" ]
            [ tr []
                [ th [] [ text "Owner" ]
                , th [] [ text " " ]
                , th [] [ text "Repository name" ]
                ]
            , tr []
                [ td []
                    [ ul [ class "navbar-nav flex-row ml-md-auto d-none d-md-flex" ]
                        [ li [ class "nav-item dropdown" ]
                            [ a
                                [ class "nav-link dropdown-toggle"
                                , href "#"
                                , attribute "data-toggle" "dropdown"
                                ]
                                [ userSelector user ]
                            , div [ class "dropdown-menu" ]
                                [ a
                                    [ class "dropdown-item"
                                    , onClick (SetNamespace user.username)
                                    ]
                                    [ userSelector user ]
                                ]
                            ]
                        ]
                    ]
                , td [ style [ "padding-left" => "5px" ] ] [ text "/" ]
                , td []
                    [ Form.input
                        [ class "form-control"
                        , style [ "width" => "250px" ]
                        , onInput SetRepositoryName
                        ]
                        []
                    ]
                ]
            ]
        , div [] [ p [] [] ]
        , div [ class "form-checkbox" ]
            [ label []
                [ Form.radio
                    [ onClick (SetPrivacy Private)
                    , name "privacyPicker"
                    , checked True
                    ]
                    []
                , Octicons.defaultOptions |> Octicons.size 24 |> Octicons.lock
                , text "Private"
                ]
            ]
        , Form.fieldset [ class "form-checkbox" ]
            [ label []
                [ Form.radio
                    [ onClick (SetPrivacy Public)
                    , name "privacyPicker"
                    ]
                    []
                , Octicons.defaultOptions |> Octicons.size 24 |> Octicons.repo
                , text "Public"
                ]
            ]
        , Html.hr [] []
        , button [ class "btn btn-success", disabled (disableNewRepoBtn model) ]
            [ text "Create repository" ]
        ]


disableNewRepoBtn : Model -> Bool
disableNewRepoBtn model =
    case model.name of
        "" ->
            True

        _ ->
            False


userSelector : User -> Html msg
userSelector user =
    span []
        [ span [ class "gravatar" ] [ Gravatar.img gravatarHeaderOption user.email ]
        , span [ style [ "padding-left" => "5px" ] ] [ text user.username ]
        ]


allowedRepoSubNameOptions : User -> List (Html Msg)
allowedRepoSubNameOptions user =
    (List.map (\un -> option [ onClick (SetRepositoryName un) ] [ text un ]) [ user.username ])


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        SetNamespace namespace ->
            { model | namespace = namespace }
                => Cmd.none

        SetRepositoryName repo_name ->
            { model | name = repo_name }
                => Cmd.none

        SetPrivacy privacy ->
            let
                privacy_text =
                    case privacy of
                        Private ->
                            "private"

                        Public ->
                            "public"
            in
                { model | privacy = privacy_text }
                    => Cmd.none

        SubmitForm ->
            let
                newModule =
                    { model | namespace = getSessionUsername (session) }

                authToken =
                    Session.maybeAuthToken session

                cmdToCreateRepo =
                    RepositoryRequest.new newModule authToken
                        |> Http.send RepositoryCreated
            in
                { newModule | errors = [] }
                    => cmdToCreateRepo

        RepositoryCreated (Err error) ->
            let
                errorMessages =
                    ErrorsData.httpErrorToList "repository creation" error errorsDecoder
            in
                { model | errors = List.map (\errorMessage -> "Form" => errorMessage) errorMessages }
                    => Cmd.none

        RepositoryCreated (Ok repo) ->
            model
                => Cmd.batch [ Route.modifyUrl (Route.ShowRepository repo.namespace repo.name) ]


errorsDecoder : Decoder (List String)
errorsDecoder =
    decode (\name privacy -> List.concat [ name, privacy ])
        |> ErrorsData.optionalError "name"
        |> ErrorsData.optionalError "privacy"


getSessionUsername : Session -> String
getSessionUsername session =
    case session.user of
        Just user ->
            user.username

        Nothing ->
            ""
