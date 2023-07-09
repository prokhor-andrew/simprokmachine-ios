#if canImport(Darwin)
@_implementationOnly import Darwin
#elseif canImport(Glibc)
@_implementationOnly import Glibc
#elseif canImport(WinSDK)
@_implementationOnly import WinSDK
#endif

fileprivate struct Lock {
#if canImport(Darwin)
  typealias Primitive = os_unfair_lock
#elseif canImport(Glibc)
  typealias Primitive = pthread_mutex_t
#elseif canImport(WinSDK)
  typealias Primitive = SRWLOCK
#else
  typealias Primitive = Int
#endif
  
  typealias PlatformLock = UnsafeMutablePointer<Primitive>
  let platformLock: PlatformLock

  private init(_ platformLock: PlatformLock) {
    self.platformLock = platformLock
  }
  
  fileprivate static func initialize(_ platformLock: PlatformLock) {
#if canImport(Darwin)
    platformLock.initialize(to: os_unfair_lock())
#elseif canImport(Glibc)
    let result = pthread_mutex_init(platformLock, nil)
    precondition(result == 0, "pthread_mutex_init failed")
#elseif canImport(WinSDK)
    InitializeSRWLock(platformLock)
#endif
  }
  
  fileprivate static func deinitialize(_ platformLock: PlatformLock) {
#if canImport(Glibc)
    let result = pthread_mutex_destroy(platformLock)
    precondition(result == 0, "pthread_mutex_destroy failed")
#endif
    platformLock.deinitialize(count: 1)
  }
  
  fileprivate static func lock(_ platformLock: PlatformLock) {
#if canImport(Darwin)
    os_unfair_lock_lock(platformLock)
#elseif canImport(Glibc)
    pthread_mutex_lock(platformLock)
#elseif canImport(WinSDK)
    AcquireSRWLockExclusive(platformLock)
#endif
  }
  
  fileprivate static func unlock(_ platformLock: PlatformLock) {
#if canImport(Darwin)
    os_unfair_lock_unlock(platformLock)
#elseif canImport(Glibc)
    let result = pthread_mutex_unlock(platformLock)
    precondition(result == 0, "pthread_mutex_unlock failed")
#elseif canImport(WinSDK)
    ReleaseSRWLockExclusive(platformLock)
#endif
  }
}

struct ManagedCriticalState<State> {
  private final class LockedBuffer: ManagedBuffer<State, Lock.Primitive> {
    deinit {
      withUnsafeMutablePointerToElements { Lock.deinitialize($0) }
    }
  }
  
  private let buffer: ManagedBuffer<State, Lock.Primitive>
  
  init(_ initial: State) {
    buffer = LockedBuffer.create(minimumCapacity: 1) { buffer in
      buffer.withUnsafeMutablePointerToElements { Lock.initialize($0) }
      return initial
    }
  }
  
  func withCriticalRegion<R>(_ critical: (inout State) throws -> R) rethrows -> R {
    try buffer.withUnsafeMutablePointers { header, lock in
      Lock.lock(lock)
      defer { Lock.unlock(lock) }
      return try critical(&header.pointee)
    }
  }
}

extension ManagedCriticalState: @unchecked Sendable where State: Sendable { }
