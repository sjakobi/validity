{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Test.Validity.Functions.CanFail
    ( succeedsOnGen
    , succeedsOnValid
    , succeeds
    , succeedsOnArbitrary
    , succeedsOnGens2
    , succeedsOnValids2
    , succeeds2
    , succeedsOnArbitrary2
    , failsOnGen
    , failsOnInvalid
    , failsOnGens2
    , failsOnInvalid2
    , validIfSucceedsOnGen
    , validIfSucceedsOnValid
    , validIfSucceedsOnArbitrary
    , validIfSucceeds
    , validIfSucceedsOnGens2
    , validIfSucceedsOnValids2
    , validIfSucceeds2
    , validIfSucceedsOnArbitrary2
    , validIfSucceedsOnGens3
    , validIfSucceedsOnValids3
    , validIfSucceeds3
    , validIfSucceedsOnArbitrary3
    ) where

import Data.GenValidity

import Test.Hspec
import Test.QuickCheck

import Test.Validity.Types

-- | The function succeeds if the input is generated by the given generator
succeedsOnGen
    :: (Show a, Show b, Show (f b), CanFail f)
    => (a -> f b) -> Gen a -> Property
succeedsOnGen func gen = forAll gen $ \a -> func a `shouldNotSatisfy` hasFailed

-- | The function succeeds if the input is generated by @genValid@
succeedsOnValid
    :: (Show a, Show b, Show (f b), GenValid a, CanFail f)
    => (a -> f b) -> Property
succeedsOnValid = (`succeedsOnGen` genValid)

-- | The function succeeds if the input is generated by @genUnchecked@
succeeds
    :: (Show a, Show b, Show (f b), GenUnchecked a, CanFail f)
    => (a -> f b) -> Property
succeeds = (`succeedsOnGen` genUnchecked)

-- | The function succeeds if the input is generated by @arbitrary@
succeedsOnArbitrary
    :: (Show a, Show b, Show (f b), Arbitrary a, CanFail f)
    => (a -> f b) -> Property
succeedsOnArbitrary = (`succeedsOnGen` arbitrary)

-- | The function fails if the input is generated by the given generator
failsOnGen
    :: (Show a, Show b, Show (f b), CanFail f)
    => (a -> f b) -> Gen a -> Property
failsOnGen func gen = forAll gen $ \a -> func a `shouldSatisfy` hasFailed

-- | The function fails if the input is generated by @genInvalid@
failsOnInvalid
    :: (Show a, Show b, Show (f b), GenInvalid a, CanFail f)
    => (a -> f b) -> Property
failsOnInvalid = (`failsOnGen` genInvalid)

-- | The function produces output that satisfies @isValid@ if it is given input
-- that is generated by the given generator.
validIfSucceedsOnGen
    :: (Show a, Show b, Show (f b), Validity b, CanFail f)
    => (a -> f b) -> Gen a -> Property
validIfSucceedsOnGen func gen =
    forAll gen $ \a ->
        case resultIfSucceeded (func a) of
            Nothing -> return () -- Can happen
            Just res -> res `shouldSatisfy` isValid

-- | The function produces output that satisfies @isValid@ if it is given input
-- that is generated by @arbitrary@.
validIfSucceedsOnValid
    :: (Show a, Show b, Show (f b), GenValid a, Validity b, CanFail f)
    => (a -> f b) -> Property
validIfSucceedsOnValid = (`validIfSucceedsOnGen` genValid)

-- | The function produces output that satisfies @isValid@ if it is given input
-- that is generated by @arbitrary@.
validIfSucceedsOnArbitrary
    :: (Show a, Show b, Show (f b), Arbitrary a, Validity b, CanFail f)
    => (a -> f b) -> Property
validIfSucceedsOnArbitrary = (`validIfSucceedsOnGen` arbitrary)

-- | The function produces output that satisfies @isValid@ if it is given input
-- that is generated by @genUnchecked@.
validIfSucceeds
    :: (Show a, Show b, Show (f b), GenUnchecked a, Validity b, CanFail f)
    => (a -> f b) -> Property
validIfSucceeds = (`validIfSucceedsOnGen` genUnchecked)

succeedsOnGens2
    :: (Show a, Show b, Show c, Show (f c), CanFail f)
    => (a -> b -> f c) -> Gen (a, b) -> Property
succeedsOnGens2 func gen =
    forAll gen $ \(a, b) -> func a b `shouldNotSatisfy` hasFailed

succeedsOnValids2
    :: (Show a, Show b, Show c, Show (f c), GenValid a, GenValid b, CanFail f)
    => (a -> b -> f c) -> Property
succeedsOnValids2 func = succeedsOnGens2 func genValid

succeeds2
    :: ( Show a
       , Show b
       , Show c
       , Show (f c)
       , GenUnchecked a
       , GenUnchecked b
       , CanFail f
       )
    => (a -> b -> f c) -> Property
succeeds2 func = succeedsOnGens2 func genUnchecked

succeedsOnArbitrary2
    :: (Show a, Show b, Show c, Show (f c), Arbitrary a, Arbitrary b, CanFail f)
    => (a -> b -> f c) -> Property
succeedsOnArbitrary2 func = succeedsOnGens2 func arbitrary

failsOnGens2
    :: (Show a, Show b, Show c, Show (f c), CanFail f)
    => (a -> b -> f c) -> Gen a -> Gen b -> Property
failsOnGens2 func genA genB =
    forAll genA $ \a -> forAll genB $ \b -> func a b `shouldSatisfy` hasFailed

failsOnInvalid2
    :: ( Show a
       , Show b
       , Show c
       , Show (f c)
       , GenInvalid a
       , GenInvalid b
       , CanFail f
       )
    => (a -> b -> f c) -> Property
failsOnInvalid2 func =
    failsOnGens2 func genInvalid genUnchecked .&&.
    failsOnGens2 func genUnchecked genInvalid

validIfSucceedsOnGens2
    :: (Show a, Show b, Show c, Show (f c), Validity c, CanFail f)
    => (a -> b -> f c) -> Gen (a, b) -> Property
validIfSucceedsOnGens2 func gen =
    forAll gen $ \(a, b) ->
        case resultIfSucceeded (func a b) of
            Nothing -> return () -- Can happen
            Just res -> res `shouldSatisfy` isValid

validIfSucceedsOnValids2
    :: ( Show a
       , Show b
       , Show c
       , Show (f c)
       , GenValid a
       , GenValid b
       , Validity c
       , CanFail f
       )
    => (a -> b -> f c) -> Property
validIfSucceedsOnValids2 func = validIfSucceedsOnGens2 func genValid

validIfSucceeds2
    :: ( Show a
       , Show b
       , Show c
       , Show (f c)
       , GenUnchecked a
       , GenUnchecked b
       , Validity c
       , CanFail f
       )
    => (a -> b -> f c) -> Property
validIfSucceeds2 func = validIfSucceedsOnGens2 func genUnchecked

validIfSucceedsOnArbitrary2
    :: ( Show a
       , Show b
       , Show c
       , Show (f c)
       , Arbitrary a
       , Arbitrary b
       , Validity c
       , CanFail f
       )
    => (a -> b -> f c) -> Property
validIfSucceedsOnArbitrary2 func = validIfSucceedsOnGens2 func arbitrary

validIfSucceedsOnGens3
    :: (Show a, Show b, Show c, Show d, Show (f d), Validity d, CanFail f)
    => (a -> b -> c -> f d) -> Gen (a, b, c) -> Property
validIfSucceedsOnGens3 func gen =
    forAll gen $ \(a, b, c) ->
        case resultIfSucceeded (func a b c) of
            Nothing -> return () -- Can happen
            Just res -> res `shouldSatisfy` isValid

validIfSucceedsOnValids3
    :: ( Show a
       , Show b
       , Show c
       , Show d
       , Show (f d)
       , GenValid a
       , GenValid b
       , GenValid c
       , Validity d
       , CanFail f
       )
    => (a -> b -> c -> f d) -> Property
validIfSucceedsOnValids3 func = validIfSucceedsOnGens3 func genValid

validIfSucceeds3
    :: ( Show a
       , Show b
       , Show c
       , Show d
       , Show (f d)
       , GenUnchecked a
       , GenUnchecked b
       , GenUnchecked c
       , Validity d
       , CanFail f
       )
    => (a -> b -> c -> f d) -> Property
validIfSucceeds3 func = validIfSucceedsOnGens3 func genUnchecked

validIfSucceedsOnArbitrary3
    :: ( Show a
       , Show b
       , Show c
       , Show d
       , Show (f d)
       , Arbitrary a
       , Arbitrary b
       , Arbitrary c
       , Validity d
       , CanFail f
       )
    => (a -> b -> c -> f d) -> Property
validIfSucceedsOnArbitrary3 func = validIfSucceedsOnGens3 func arbitrary
