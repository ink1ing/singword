import Foundation
import MusicKit

final class AppleMusicAuthorizationService {
    func currentAccessStatus() async -> LibraryAccessStatus {
        await resolveAccessStatus(requestAuthorization: false)
    }

    func requestAccessStatus() async -> LibraryAccessStatus {
        await resolveAccessStatus(requestAuthorization: true)
    }

    private func resolveAccessStatus(requestAuthorization: Bool) async -> LibraryAccessStatus {
        let authorizationStatus = requestAuthorization
            ? await MusicAuthorization.request()
            : MusicAuthorization.currentStatus

        switch authorizationStatus {
        case .authorized:
            break
        case .notDetermined:
            return .needsAuthorization
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .unavailable(message: "Apple Music 权限状态未知")
        }

        do {
            let subscription = try await MusicSubscription.current
            guard subscription.hasCloudLibraryEnabled else {
                return .subscriptionUnavailable
            }

            let storefront = try await MusicDataRequest.currentCountryCode
            guard !storefront.isEmpty else {
                return .regionUnavailable
            }

            return .ready(storefront: storefront)
        } catch let error as MusicSubscription.Error {
            switch error {
            case .permissionDenied:
                return .denied
            case .privacyAcknowledgementRequired:
                return .unavailable(message: "需要先确认 Apple Music 隐私授权")
            case .unknown:
                return .unavailable(message: "无法读取 Apple Music 订阅状态")
            @unknown default:
                return .unavailable(message: error.localizedDescription)
            }
        } catch {
            return .unavailable(message: error.localizedDescription)
        }
    }
}
