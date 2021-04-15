# BUSINESS_UNITS

Please populate this file with information about how this application/library uses business units.

If the application/library does not deal with data in our business domain (an example would be a library that just contains string utilities), then a BUSINESS_UNITS.md file is not required and this PR can be closed.

Use the template below and fill in the information required. This document will help work out what work is required when adding new business units in the future, or if we want to bring functionality that exists in one business unit to our other business unit/s. Please read [the BDR](https://know.simplybusiness.io/decision-records/081-tracking-changes-required-when-adding-business-units/081-tracking-changes-required-when-adding-business-units.md) for more information and context.

Some examples of BUSINESS_UNIT.md files:

https://github.com/simplybusiness/bar/blob/master/BUSINESS_UNITS.md
https://github.com/simplybusiness/eventification/blob/master/BUSINESS_UNITS.md
A repo containing multiple applications: https://github.com/simplybusiness/unified-profile-service/blob/master/BUSINESS_UNITS.md


If this application requires changes when a new business unit is added, please add it to the list in [this feature test in business_rules](https://github.com/simplybusiness/business_rules/blob/master/spec/business_unit.feature#L62-L79).

## <App/Library Name>

### Application Type

<Single-Tenant/Multi-Tenant>

### Action Always Required on Creation of New Business Unit?

<Yes/No>

### How System Uses Business Units

<A description of how the system's logic interacts with data from one or more business units, and what, if anything, needs changing when a new business unit is introduced>