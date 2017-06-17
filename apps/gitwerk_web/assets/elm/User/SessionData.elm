module User.SessionData exposing (..)

import User.UserData exposing (User)

type alias Session =
    { user : Maybe User }
