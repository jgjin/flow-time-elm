port module FlowTime exposing (main)

import Array
import Browser
import Duration
import Html exposing (Html, aside, div, form, h1, input, li, main_, nav, p, text, ul)
import Html.Attributes exposing (class, classList, style, type_, value)
import Html.Events exposing (onClick, onInput, onMouseOut, onMouseOver, onSubmit)
import List.Extra exposing (find)
import Quantity
import Time


type Status
    = Idle
    | Resting
    | Working Int


type Hover
    = None
    | Header
    | Body


type alias Task =
    { id : Int
    , name : String
    , accumDuration : Duration.Duration
    , hover : Hover
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
                  , hover = None
                  }
                , { id = -1
                  , name = "Peel bananas"
                  , accumDuration = Duration.seconds 0
                  , hover = None
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
    | Hovering Int Hover


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Adding ->
            ( { model
                | tasks = Array.push (Task model.nextTaskId model.nextTaskName (Duration.seconds 0) None) model.tasks
                , nextTaskId = model.nextTaskId + 1
                , nextTaskName = ""
              }
            , Cmd.none
            )

        Deleting id ->
            let
                tasks =
                    Array.filter (\task -> task.id /= id) model.tasks
            in
            case model.status of
                Working activeId ->
                    if id == activeId then
                        ( { model
                            | status = Resting
                            , tasks = tasks
                          }
                        , Cmd.none
                        )

                    else
                        ( { model
                            | tasks = tasks
                          }
                        , Cmd.none
                        )

                _ ->
                    ( { model
                        | tasks = tasks
                      }
                    , Cmd.none
                    )

        Toggling id ->
            case model.status of
                Working activeId ->
                    if id == activeId then
                        ( { model
                            | status = Resting
                          }
                        , Cmd.none
                        )

                    else
                        ( { model
                            | status = Working id
                          }
                        , Cmd.none
                        )

                _ ->
                    ( { model
                        | status = Working id
                      }
                    , Cmd.none
                    )

        UpdatingName newName ->
            ( { model
                | nextTaskName = newName
              }
            , Cmd.none
            )

        UpdatingDuration _ ->
            case model.status of
                Working activeId ->
                    ( { model
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
                    , Cmd.none
                    )

                Resting ->
                    case Quantity.compare (Duration.seconds 5) model.accumDuration of
                        LT ->
                            ( { model
                                | accumDuration = Quantity.minus (Duration.seconds 5) model.accumDuration
                              }
                            , Cmd.none
                            )

                        _ ->
                            ( { model
                                | accumDuration = Duration.seconds 0
                                , status = Idle
                              }
                            , playSound "ding.mp3"
                            )

                Idle ->
                    ( model, Cmd.none )

        Hovering hoverId hover ->
            ( { model
                | tasks =
                    Array.map
                        (\task ->
                            if task.id == hoverId then
                                { task | hover = hover }

                            else
                                task
                        )
                        model.tasks
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 UpdatingDuration


simpleClassList : List String -> Html.Attribute msg
simpleClassList classes =
    classList (List.map (\class -> ( class, True )) classes)


view : Model -> Html Msg
view model =
    div [ simpleClassList [ "row", "min-vh-100", "flex-column", "flex-md-row" ] ]
        [ aside
            [ simpleClassList [ "col-12", "col-md-2", "p-0", "flex-shrink-1" ]
            , style "max-height" "100vh"
            , style "overflow-y" "auto"
            , style "scrollbar-width" "none"
            , style "background-color" "#0063cd"
            ]
            [ nav [ simpleClassList [ "navbar", "navbar-expand", "navbar-dark", "flex-md-column", "flex-row", "align-items-start", "py-2" ] ]
                [ div [ simpleClassList [ "collapse", "navbar-collapse", "w-100" ] ]
                    [ ul
                        [ simpleClassList [ "flex-md-column", "flex-row", "navbar-nav", "w-100", "justify-content-between" ]
                        , style "white-space" "nowrap"
                        , style "overflow-x" "auto"
                        , style "scrollbar-width" "none"
                        , style "background-color" "#0063cd"
                        ]
                        (List.append (viewTasks model.tasks) (viewForm model.nextTaskName))
                    ]
                ]
            ]
        , main_ [ simpleClassList [ "col", "bg-faded", "py-3", "flex-grow-1" ] ]
            [ div [ simpleClassList [ "d-flex", "justify-content-center", "flex-wrap", "flex-md-no-wrap", "align-items-center", "pt-3", "pb-2", "mb-3", "h-100" ] ]
                [ div [ simpleClassList [ "d-flex", "align-items-center" ] ]
                    [ div [ class "container" ]
                        [ viewStatus model.tasks model.status
                        , viewAccumDuration model.status model.accumDuration
                        ]
                    ]
                ]
            ]
        ]


viewTasks : Array.Array Task -> List (Html Msg)
viewTasks tasks =
    Array.map viewTask tasks
        |> Array.toList


viewTask : Task -> Html Msg
viewTask task =
    li [ simpleClassList [ "nav-item", "m-1" ] ]
        [ div [ class "card", style "max-width" "80vw" ]
            [ div
                [ classList [ ( "card-header", True ), ( "bg-primary", task.hover == Header ) ]
                , onClick (Deleting task.id)
                , onMouseOver (Hovering task.id Header)
                , onMouseOut (Hovering task.id None)
                ]
                [ p
                    [ simpleClassList [ "card-title", "text-center", "text-truncate", "m-0" ]
                    , style "line-height" "2.5rem"
                    , style "font-weight" "bold"
                    ]
                    [ text
                        (case task.hover of
                            Header ->
                                "Mark as done"

                            _ ->
                                task.name
                        )
                    ]
                ]
            , div
                [ classList [ ( "card-body", True ), ( "font-weight-bold", task.hover == Body ) ]
                , onClick (Toggling task.id)
                , onMouseOver (Hovering task.id Body)
                , onMouseOut (Hovering task.id None)
                ]
                [ p [ simpleClassList [ "text-center m-0" ] ]
                    [ text (viewDuration task.accumDuration) ]
                ]
            ]
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


viewForm : String -> List (Html Msg)
viewForm nextTaskName =
    [ li [ simpleClassList [ "nav-item", "m-1" ] ]
        [ div [ class "card", style "min-width" "10rem" ]
            [ div [ class "card-header" ]
                [ form [ class "w-100", style "min-height" "2.5rem", onSubmit Adding ]
                    [ input [ class "w-100", type_ "text", value nextTaskName, onInput UpdatingName ] []
                    ]
                ]
            , div [ class "card-body" ]
                [ p [ simpleClassList [ "text-center", "m-0" ] ]
                    [ text "00:00:00" ]
                ]
            ]
        ]
    ]


viewStatus : Array.Array Task -> Status -> Html Msg
viewStatus tasks status =
    let
        primaryText =
            case status of
                Idle ->
                    "Let's get to work!"

                Resting ->
                    "Break time! 😌"

                Working activeId ->
                    find (\task -> task.id == activeId) (Array.toList tasks)
                        |> Maybe.map (\task -> task.name)
                        |> Maybe.withDefault "Keep going! You got this!"
    in
    h1 [ class "text-center", style "font-size" "4rem", style "font-weight" "bold" ]
        [ text primaryText
        ]


viewAccumDuration : Status -> Duration.Duration -> Html Msg
viewAccumDuration status duration =
    let
        durationText =
            case status of
                Idle ->
                    "🙌"

                Resting ->
                    viewDuration (Quantity.divideBy 5 duration)

                Working _ ->
                    viewDuration duration
    in
    p [ class "text-center", style "font-size" "3rem" ]
        [ text durationText ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


port playSound : String -> Cmd msg
