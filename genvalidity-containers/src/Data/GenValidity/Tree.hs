{-# OPTIONS_GHC -Wno-orphans #-}

module Data.GenValidity.Tree where

import Data.GenValidity
import Data.Validity.Tree ()

import Test.QuickCheck

import Data.Tree

instance GenUnchecked a =>
         GenUnchecked (Tree a) where
    genUnchecked = genTreeOf genUnchecked

instance GenValid a =>
         GenValid (Tree a) where
    genValid = genTreeOf genValid

-- | There should be at least one invalid element, either it's here or it's
-- further down the tree.
instance (GenUnchecked a, GenInvalid a) =>
         GenInvalid (Tree a) where
    genInvalid =
        sized $ \n -> do
            size <- upTo n
            (a, b) <- genSplit size
            oneof
                [ Node <$> resize a genInvalid <*> resize b genUnchecked
                , Node <$> resize a genUnchecked <*> resize b genInvalid
                ]

-- | Generate a tree of values that are generated as specified.
--
-- This takes the size parameter much better into account
genTreeOf :: Gen a -> Gen (Tree a)
genTreeOf func =
    sized $ \n -> do
        size <- upTo n
        (a, b) <- genSplit size
        value <- resize a func
        forest <- resize b $ genListOf $ genTreeOf func
        return $ Node value forest
