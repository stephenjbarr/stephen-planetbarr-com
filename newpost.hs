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
import Data.Text
import Data.Text.Format as F

-- https://hackage.haskell.org/package/text-0.11.2.3/docs/Data-Text-Lazy-Builder.html#t:Builder
-- let i :: Int = 32
-- λ> left 4 '0' i

datePrefix :: (Integer, Int, Int) -> Text
datePrefix = error "undefined"

main = do
    putStrLn "New post!!!"
    now <- getCurrentTime
    timezone <- getCurrentTimeZone
    let zoneNow = utcToLocalTime timezone now
    let (year, month, day) = toGregorian $ localDay zoneNow
    putStrLn $ "Year: " ++ show year
    putStrLn $ "Month: " ++ show month
    putStrLn $ "Day: " ++ show day

