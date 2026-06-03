import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @ObservedObject var viewModel: LoveViewModel
    @State private var page = 0
    @State private var selectedDate = Date()
    @State private var myName = ""
    @State private var partnerName = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isBeating = false

    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()

            TabView(selection: $page) {
                welcomePage.tag(0)
                namesPage.tag(1)
                datePage.tag(2)
                photoPage.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .animation(.easeInOut(duration: 0.35), value: page)
    }

    // MARK: - Page 1: Welcome
    private var welcomePage: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.primaryPink.opacity(0.25))
                    .frame(width: 220, height: 220)
                    .scaleEffect(isBeating ? 1.08 : 1.0)

                Text("💕")
                    .font(.system(size: 110))
                    .scaleEffect(isBeating ? 1.06 : 1.0)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    isBeating = true
                }
            }

            Spacer().frame(height: 40)

            Text("LoveDays")
                .font(AppTheme.counterFont(size: 42))
                .foregroundStyle(AppTheme.deepRose)

            Text("Trân trọng từng ngày bên nhau")
                .font(AppTheme.bodyFont())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            Spacer()

            nextBtn("Bắt đầu ❤️") { page = 1 }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
        }
    }

    // MARK: - Page 2: Names
    private var namesPage: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("👫").font(.system(size: 80))
            Spacer().frame(height: 24)
            Text("Hai người yêu nhau")
                .font(AppTheme.titleFont())
                .foregroundStyle(AppTheme.deepRose)
            Text("Nhập tên của hai bạn").font(AppTheme.bodyFont()).foregroundStyle(.secondary).padding(.top, 6)
            Spacer().frame(height: 32)

            VStack(spacing: 14) {
                inputField("Tên của bạn", icon: "person.fill", text: $myName)
                inputField("Tên người ấy", icon: "heart.fill",  text: $partnerName)
            }
            .padding(.horizontal, 32)

            Spacer()
            navRow(back: { page = 0 }, next: {
                viewModel.saveMyName(myName)
                viewModel.savePartnerName(partnerName)
                page = 2
            })
        }
    }

    // MARK: - Page 3: Date
    private var datePage: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("📅").font(.system(size: 80))
            Spacer().frame(height: 24)
            Text("Ngày bắt đầu yêu")
                .font(AppTheme.titleFont())
                .foregroundStyle(AppTheme.deepRose)
            Text("Khi nào các bạn bắt đầu?")
                .font(AppTheme.bodyFont()).foregroundStyle(.secondary).padding(.top, 6)
            Spacer().frame(height: 24)

            DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(AppTheme.deepRose)
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.85)))
                .padding(.horizontal, 20)

            Spacer()
            navRow(back: { page = 1 }, next: {
                viewModel.saveStartDate(selectedDate)
                page = 3
            })
        }
    }

    // MARK: - Page 4: Photo
    private var photoPage: some View {
        VStack(spacing: 0) {
            Spacer()

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Group {
                    if let img = viewModel.couplePhoto {
                        Image(uiImage: img)
                            .resizable().scaledToFill()
                            .frame(width: 180, height: 180)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(AppTheme.softPink)
                            .frame(width: 180, height: 180)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(AppTheme.deepRose)
                                    Text("Thêm ảnh đôi")
                                        .font(AppTheme.bodyFont(size: 14))
                                        .foregroundStyle(AppTheme.deepRose)
                                }
                            )
                    }
                }
                .overlay(Circle().stroke(AppTheme.primaryPink, lineWidth: 3))
                .shadow(color: AppTheme.primaryPink.opacity(0.4), radius: 12)
            }
            .onChange(of: selectedPhoto) { item in
                Task {
                    if let data = try? await item?.loadTransferable(type: Data.self) {
                        viewModel.saveCouplePhoto(data)
                    }
                }
            }

            Spacer().frame(height: 28)
            Text("Ảnh của hai bạn").font(AppTheme.titleFont()).foregroundStyle(AppTheme.deepRose)
            Text("Không bắt buộc — có thể thêm sau")
                .font(AppTheme.bodyFont()).foregroundStyle(.secondary).padding(.top, 6)

            Spacer()
            navRow(back: { page = 2 }, next: {
                Task {
                    _ = await NotificationManager.shared.requestPermission()
                    NotificationManager.shared.scheduleAllReminders(
                        startDate: viewModel.startDate, partnerName: viewModel.partnerName,
                        myBirthday: viewModel.myBirthday, partnerBirthday: viewModel.partnerBirthday,
                        myName: viewModel.myName)
                }
                viewModel.completeOnboarding()
            }, nextLabel: "Hoàn thành 🎉")
        }
    }

    // MARK: - Helpers
    private func inputField(_ placeholder: String, icon: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(AppTheme.deepRose).frame(width: 22)
            TextField(placeholder, text: text).font(AppTheme.bodyFont())
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14)
            .fill(Color.white.opacity(0.9))
            .shadow(color: AppTheme.primaryPink.opacity(0.25), radius: 8, y: 4))
    }

    private func nextBtn(_ label: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.impact(.medium)
            action()
        } label: {
            Text(label).primaryButtonStyle()
        }
    }

    private func navRow(back: @escaping () -> Void,
                        next: @escaping () -> Void,
                        nextLabel: String = "Tiếp theo") -> some View {
        HStack(spacing: 16) {
            Button { HapticManager.impact(.light); back() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .secondaryButtonStyle()
            }
            nextBtn(nextLabel, action: next)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 56)
    }
}

extension View {
    fileprivate func secondaryButtonStyle() -> some View {
        self.foregroundStyle(AppTheme.deepRose)
            .frame(width: 52, height: 52)
            .background(Circle().fill(Color.white.opacity(0.9))
                .shadow(color: AppTheme.primaryPink.opacity(0.3), radius: 8, y: 4))
    }
}
