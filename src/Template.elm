module Main exposing (Model, Msg(..), view)

import Html exposing (..)
import Html.Attributes exposing (..)


type alias Model =
    { poop : String
    }


type Msg
    = Check
    | Done


view : Model -> Html Msg
view model =
    div [ classList ["row", "min-vh-100", "flex-column", "flex-md-row"] ]
        [ aside [ classList ["col-12", "col-md-2", "p-0", "bg-dark", "flex-shrink-1"] ]
              [ nav [ classList ["navbar", "navbar-expand", "navbar-dark", "bg-dark", "flex-md-column", "flex-row", "align-items-start", "py-2"] ]
                    [ div [ classLisbb ]

                    ]

              ]

        ]


-- <div class="row min-vh-100 flex-column flex-md-row">
--     <aside class="col-12 col-md-2 p-0 bg-dark flex-shrink-1">
--         <nav class="navbar navbar-expand navbar-dark bg-dark flex-md-column flex-row align-items-start py-2">
--             <div class="collapse navbar-collapse w-100" style="white-space: nowrap; overflow-x: auto;">
--                 <ul class="flex-md-column flex-row navbar-nav w-100 justify-content-between" style="white-space: nowrap; overflow-x: auto;">
--                     <li class="nav-item m-1">
--                         <div class="card">
--                             <div class="card-header">
--                                 <p class="card-title text-center text-truncate m-0">
--                                     Hello world! I am 🌽
--                                 </p>
--                             </div>
--                             <div class="card-body">
--                                 <p class="text-center m-0">
--                                     00 : 00 : 00
--                                 </p>
--                             </div>
--                         </div>
--                     </li>
--                     <li class="nav-item m-1">
--                         <div class="card" style="max-width: 80vw;">
--                             <div class="card-header">
--                                 <p class="card-title text-center text-truncate m-0" style="line-height: 2.5rem;">
--                                     It was the best of times, it was the worst of times. Charley Charles Charl
--                                 </p>
--                             </div>
--                             <div class="card-body">
--                                 <p class="text-center m-0">
--                                     00 : 00 : 00
--                                 </p>
--                             </div>
--                         </div>
--                     </li>
--                     <li class="nav-item m-1">
--                         <div class="card" style="min-width: 10rem;">
--                             <div class="card-header">
--                                 <form class="w-100" style="min-height: 2.5rem;">
--                                     <input type="text" placeholder="poop" class="w-100">
--                                 </form>
--                             </div>
--                             <div class="card-body">
--                                 <p class="text-center m-0">
--                                     00 : 00 : 00
--                                 </p>
--                             </div>
--                         </div>
--                     </li>
--                 </ul>
--             </div>
--         </nav>
--     </aside>
--     <main class="col bg-faded py-3 flex-grow-1">
--         <h2>Shucking corn...</h2>
--         <p>
--             00:01:23
--         </p>
--     </main>
-- </div>
