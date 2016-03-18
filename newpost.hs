{-# LANGUAGE OverloadedStrings, ScopedTypeVariables, GeneralizedNewtypeDeriving #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  newpost
-- Copyright   :  (C) 2015-2016, Stephen J. Barr
-- License     :  None
-- Maintainer  :  Stephen J. Barr <stephen@planetbarr.com>
-- Stability   :  experimental
--
-- Simple script to create stub files necessary for a new post
-- 
----------------------------------------------------------------------------


import Data.Time.Clock
import Data.Time.Calendar
import Data.Time.LocalTime
import Data.Text as T
import Data.Text.Lazy.Builder as T
import Data.Text.Format as T
import qualified TextShow as TS (toText)

-- https://hackage.haskell.org/package/text-0.11.2.3/docs/Data-Text-Lazy-Builder.html#t:Builder


pad2 :: Int -> T.Text
pad2 x =  TS.toText $ left 2 '0' x


-- datePrefix :: (Integer, Int, Int) -> Text
-- datePrefix (y_i, m_i, d_i) = intersperse 
--   y = show y_i
--   m      m_i 

main = do
    putStrLn "New post!!!"
    now <- getCurrentTime
    timezone <- getCurrentTimeZone
    let zoneNow = utcToLocalTime timezone now
    let (year, month, day) = toGregorian $ localDay zoneNow
    putStrLn $ "Year: " ++ show year
    putStrLn $ "Month: " ++ show month
    putStrLn $ "Day: " ++ show day

