# Code Documentation Rules

This document outlines the strict mandatory documentation standards for the FleetMan project. Any new code written for this project **must** be documented in accordance with these rules to ensure clarity, debuggability, and maintainability.

## 1. Web (TypeScript / React / Next.js)

All Web code must use **JSDoc** formatted comments.

### 1.1 Types and Interfaces
Every custom Type and Interface must include a JSDoc block explaining its purpose and property details if they are non-obvious.

```typescript
/**
 * Data Transfer Object for creating a new vehicle.
 * Ensures the minimum required data is captured when adding vehicles.
 */
export interface CreateVehicleDTO {
  /** The unique alphanumeric license plate number. */
  plate_number: string;
  /** The make/manufacturer of the vehicle (e.g., Toyota). */
  make: string;
  // ...
}
```

### 1.2 Functions and Methods
Document the function's purpose, parameters, and returns. If a function throws errors, declare what triggers the exception.

```typescript
/**
 * Retrieves a vehicle by its UUID.
 * 
 * @param id The vehicle UUID.
 * @returns The associated Vehicle object.
 * @throws Error if the vehicle is not found or user is unauthorized.
 */
async function getVehicleById(id: string): Promise<Vehicle> {
  // ...
}
```

### 1.3 React Components
Document the expected props and the core functionality of the component.

```tsx
/**
 * Displays detailed information about a specific vehicle.
 * @returns React component rendering the vehicle card and specification metrics.
 */
export default function VehicleDetailPage() {
  // ...
}
```

## 2. Mobile (Flutter / Dart)

All Mobile code must use **DartDoc** formatted comments (`///`).

### 2.1 Classes and Models
```dart
/// Represents a physical vehicle in the system.
///
/// Contains fundamental identity information required for auditing and fleet tracking.
class Vehicle {
  /// The system-generated UUID for the vehicle.
  final String id;
  // ...
}
```

### 2.2 Methods
Document what the method does, the parameters, return types, and exceptions.

```dart
  /// Authenticates a user using email and password.
  /// 
  /// Throws an [AuthException] if the credentials are invalid or missing.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // ...
  }
```

## 3. General Architecture Documentation

When complex architectural choices are made (e.g., caching layers, specialized database transactions, anti-cheat implementations), inline block comments outlining the **"Why"** must be included.

```typescript
// ANTI-CHEAT OVERRIDE: We bypass local time entirely and rely
// on the cryptographically signed Supabase RPC response to ensure 
// device time-spoofing is physically impossible.
```

By adhering to these rules, all components can be debugged significantly faster, as intentions map directly onto execution behavior, minimizing cognitive overhead for developers.
