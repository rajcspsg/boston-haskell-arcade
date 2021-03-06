-- | Example FRP-style game.

module Bha.Game.Impl.BananaExample
  ( moment
  ) where

import Bha.Banana.Prelude
import Bha.Banana.Tick

moment
  :: Events TermEvent
  -> Banana (Behavior Scene, Events ())
moment eEvent = mdo
  eTick :: Events NominalDiffTime <-
    momentTick (Just 1) (TickTeardown <$ eDone)

  bElapsed :: Behavior NominalDiffTime <-
    accumB 0 ((+) <$> eTick)

  let
    eDone :: Events ()
    eDone =
      leftmostE
        [ () <$ filterE (== EventKey KeyEsc False) eEvent
        , () <$ filterE (> 10) eCount
        ]

  eCount :: Events Int <-
    accumE 0 ((+1) <$ eEvent)

  bCount :: Behavior Int <-
    stepper 0 eCount

  let
    bCells :: Behavior Cells
    bCells =
      f <$> bCount <*> bElapsed
     where
      f :: Int -> NominalDiffTime -> Cells
      f n elapsed =
        mconcat
          [ text 0 0 mempty mempty "I am a banana game!"
          , text 0 2 mempty mempty "Let's count to 10."
          , text 2 4 mempty mempty (show n)
          , text 0 6 mempty mempty ("Elapsed time: " ++ show elapsed)
          ]
  let
    bScene :: Behavior Scene
    bScene =
      Scene
        <$> bCells
        <*> pure NoCursor

  pure (bScene, eDone)
