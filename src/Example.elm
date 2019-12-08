module Example exposing (main)

import Array
import Browser
import Duration
import Html exposing (Html, button, div, form, input, li, p, text, ul)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Quantity
import Time


type Status
    = Idle
    | Resting
    | Working Int


type alias Task =
    { id : Int
    , name : String
    , accumDuration : Duration.Duration
    }


type alias Model =
    { status : Status
    , accumDuration : Duration.Duration
    , tasks : Array.Array Task
    , nextTaskId : Int
    , nextTaskName : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { status = Idle
      , accumDuration = Duration.seconds 0
      , tasks =
            Array.fromList
                [ { id = -2
                  , name = "Shuck corn"
                  , accumDuration = Duration.seconds 0
                  }
                , { id = -1
                  , name = "Peel bananas"
                  , accumDuration = Duration.seconds 0
                  }
                ]
      , nextTaskId = 0
      , nextTaskName = ""
      }
    , Cmd.none
    )


type Msg
    = Adding
    | Deleting Int
    | Toggling Int
    | UpdatingName String
    | UpdatingDuration Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        updatedModel =
            case msg of
                Adding ->
                    { model
                        | tasks = Array.push (Task model.nextTaskId model.nextTaskName (Duration.seconds 0)) model.tasks
                        , nextTaskId = model.nextTaskId + 1
                        , nextTaskName = ""
                    }

                Deleting id ->
                    let
                        tasks =
                            Array.filter (\task -> task.id /= id) model.tasks
                    in
                    case model.status of
                        Working activeId ->
                            if id == activeId then
                                { model
                                    | status = Resting
                                    , tasks = tasks
                                }

                            else
                                { model
                                    | tasks = tasks
                                }

                        _ ->
                            { model
                                | tasks = tasks
                            }

                Toggling id ->
                    case model.status of
                        Working activeId ->
                            if id == activeId then
                                { model
                                    | status = Resting
                                }

                            else
                                { model
                                    | status = Working id
                                }

                        _ ->
                            { model
                                | status = Working id
                            }

                UpdatingName newName ->
                    { model
                        | nextTaskName = newName
                    }

                UpdatingDuration _ ->
                    case model.status of
                        Working activeId ->
                            { model
                                | accumDuration = Quantity.plus (Duration.seconds 1) model.accumDuration
                                , tasks =
                                    Array.map
                                        (\task ->
                                            if task.id == activeId then
                                                { task
                                                    | accumDuration = Quantity.plus (Duration.seconds 1) task.accumDuration
                                                }

                                            else
                                                task
                                        )
                                        model.tasks
                            }

                        Resting ->
                            case Quantity.compare (Duration.seconds 5) model.accumDuration of
                                LT ->
                                    { model
                                        | accumDuration = Quantity.minus (Duration.seconds 5) model.accumDuration
                                    }

                                _ ->
                                    { model
                                        | accumDuration = Duration.seconds 0
                                        , status = Idle
                                    }

                        Idle ->
                            model
    in
    ( updatedModel, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 UpdatingDuration


view : Model -> Html Msg
view model =
    div []
        [ viewTasks model.tasks
        , viewForm model.nextTaskName
        , viewStatus model.status
        , viewAccumDuration model.accumDuration
        ]


viewTasks : Array.Array Task -> Html Msg
viewTasks tasks =
    ul []
        (Array.map viewTask tasks
            |> Array.toList
        )


viewTask : Task -> Html Msg
viewTask task =
    li []
        [ p [ onClick (Toggling task.id) ]
            [ text task.name
            ]
        , p [ onClick (Toggling task.id) ]
            [ text (viewDuration task.accumDuration)
            ]
        , button [ onClick (Deleting task.id) ] []
        ]


viewDuration : Duration.Duration -> String
viewDuration duration =
    let
        hours =
            Duration.inHours duration
                |> floor
                |> String.fromInt
                |> String.padLeft 2 '0'

        minutes =
            Duration.inMinutes duration
                |> floor
                |> (\totalMinutes -> modBy 60 totalMinutes)
                |> String.fromInt
                |> String.padLeft 2 '0'

        seconds =
            Duration.inSeconds duration
                |> floor
                |> (\totalSeconds -> modBy 60 totalSeconds)
                |> String.fromInt
                |> String.padLeft 2 '0'
    in
    hours ++ ":" ++ minutes ++ ":" ++ seconds


viewForm : String -> Html Msg
viewForm nextTaskName =
    form [ onSubmit Adding ]
        [ input [ type_ "text", value nextTaskName, onInput UpdatingName ] []
        ]


viewStatus : Status -> Html Msg
viewStatus status =
    case status of
        Idle ->
            p []
                [ text "idle" ]

        Resting ->
            p []
                [ text "resting" ]

        Working activeId ->
            p []
                [ text ("working " ++ String.fromInt activeId) ]


viewAccumDuration : Duration.Duration -> Html Msg
viewAccumDuration duration =
    p []
        [ text (viewDuration duration) ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
