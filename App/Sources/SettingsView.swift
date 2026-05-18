import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: ObservatoryStore

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.settingsTitle())
                        .font(.title2.weight(.semibold))
                    Text(L10n.settingsSubtitle())
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 4)
            }

            Section(L10n.settingsLocationSection()) {
                Toggle(
                    L10n.settingsLocationToggle(),
                    isOn: Binding(
                        get: { store.usesDeviceLocation },
                        set: { newValue in
                            store.setUsesDeviceLocation(newValue)
                        }
                    )
                )
                .toggleStyle(.switch)

                Text(L10n.settingsLocationDescription())
                    .foregroundStyle(.secondary)

                LabeledContent(L10n.currentLocationFallback()) {
                    Text(store.usesDeviceLocation ? L10n.settingsLocationCurrent(store.bundle.location.name) : L10n.settingsLocationSaved(store.bundle.location.name))
                        .foregroundStyle(.secondary)
                }

                LabeledContent(L10n.settingsLocationStatusLabel()) {
                    Text(
                        L10n.settingsLocationHelper(
                            usingDeviceLocation: store.usesDeviceLocation,
                            accessEnabled: store.locationAccessEnabled
                        )
                    )
                    .foregroundStyle(.secondary)
                }

                if store.usesDeviceLocation && !store.locationAccessEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.settingsLocationGrantTitle())
                            .font(.headline)
                        Text(L10n.settingsLocationGrantBody())
                            .foregroundStyle(.secondary)
                        HStack(spacing: 10) {
                            Button(L10n.settingsLocationGrantButton()) {
                                store.requestLocationAccess()
                            }

                            if store.locationPermissionDenied {
                                Button(L10n.settingsOpenButton()) {
                                    store.openLocationSystemSettings()
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Section(L10n.settingsNotificationsSection()) {
                Toggle(
                    L10n.settingsNotificationsToggle(),
                    isOn: Binding(
                        get: { store.notificationsArmed && store.notificationsEnabled },
                        set: { newValue in
                            if newValue {
                                if store.notificationsEnabled {
                                    store.setNotificationsArmed(true)
                                } else {
                                    store.requestNotificationAccess()
                                }
                            } else {
                                store.setNotificationsArmed(false)
                            }
                        }
                    )
                )
                .toggleStyle(.switch)

                Text(L10n.settingsNotificationsDescription())
                    .foregroundStyle(.secondary)

                LabeledContent(L10n.controlsNotificationsLabel()) {
                    Text(L10n.settingsNotificationsHelper(enabled: store.notificationsEnabled, armed: store.notificationsArmed))
                        .foregroundStyle(.secondary)
                }

                if store.notificationAuthorizationState != .authorized {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.settingsGrantAccessTitle())
                            .font(.headline)
                        Text(L10n.settingsGrantAccessBody())
                            .foregroundStyle(.secondary)
                        HStack(spacing: 10) {
                            Button(L10n.settingsGrantAccessButton()) {
                                store.requestNotificationAccess()
                            }

                            if store.notificationAuthorizationState == .denied {
                                Button(L10n.settingsOpenButton()) {
                                    store.openNotificationSystemSettings()
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Section(L10n.settingsTestSection()) {
                Text(L10n.settingsTestBody())
                    .foregroundStyle(.secondary)

                Button(L10n.settingsSendTestButton()) {
                    store.scheduleTestNotification()
                }
                .disabled(!store.notificationsEnabled || !store.notificationsArmed)

                if store.lastTestScheduledAt != nil {
                    Text(L10n.settingsTestQueued())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 560, height: 560)
    }
}
