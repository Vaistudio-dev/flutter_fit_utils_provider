## 1.0.0

- Added FitProvider
- Added FitFormProvider
- Added pre-built DataProvider
- Added pre-built ItemsProvider
- Updated README

## 1.0.1

- Added a getter for _service inside DataProvider
- Added a getter for _service inside ItemsProvider

## 1.0.2

- Added service initialization inside the initialization of DataProvider and ItemsProvider

## 1.0.3

- Added option to not automatically assign the userId to an instance in DataProvider and ItemsProvider.

## 2.0.0

- Made service public and late initializable in DataProvider and ItemsProvider.
- Removed getService() in DataProvider and ItemsProvider.

## 2.1.0
- Made userId parameter nullable in DataProvider.initialize() and ItemsProvider.initialize()

## 2.1.1
- Fixed delete method of ItemsProvider

## 2.1.2

- Updated dependencies

## 2.1.3

- Fixed ItemsProvider's update method.

## 2.1.4

- Made FitProvider's service non-final.

## 2.1.5
.

## 2.2.0

- Implemented events for DataProvider and ItemsProvider with flutter_fit_events

## 2.2.1

- Added defaults description to provider events.

## 2.2.2

- Added Operation failed event when a create, update or delete operation has failed inside a provider.