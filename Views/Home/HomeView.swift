import SwiftUI
import PhotosUI

struct HomeView: View {
    @ObservedObject var viewModel: LoveViewModel
    @State private var selectedMyPhoto: PhotosPickerItem?
    @State private var selectedPartnerPhoto: PhotosPickerItem?
    @State private var floatingHearts: [FloatingHeart] = []

    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            floatingHeartsLayer

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    profilesSection
                    counterSection
                    detailSection
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .onChange(of: selectedMyPhoto) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    viewModel.saveMyPhoto(data)
                }
            }
        }
        .onChange(of: selectedPartnerPhoto) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    viewModel.savePartnerPhoto(data)
                }
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        TabHeader(emoji: "💕", title: viewModel.displayTitle,
                  subtitle: "Từ \(viewModel.formattedStartDate)") {
            Button {
                HapticManager.heartbeat()
                viewModel.triggerHeart()
                spawnHearts()
            } label: {
                Image(systemName: viewModel.heartAnimating ? "heart.fill" : "heart")
                    .font(.system(size: 26))
                    .foregroundStyle(AppTheme.heartRed)
                    .scaleEffect(viewModel.heartAnimating ? 1.3 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: viewModel.heartAnimating)
            }
        }
    }

    // MARK: - Profiles
    private var profilesSection: some View {
        HStack(spacing: 0) {
            profileAvatar(
                image: viewModel.myPhoto,
                name: viewModel.myName.isEmpty ? "Bạn" : viewModel.myName,
                birthday: viewModel.myBirthday,
                picker: $selectedMyPhoto
            )

            Spacer()
            Text("❤️").font(.system(size: 32))
            Spacer()

            profileAvatar(
                image: viewModel.partnerPhoto,
                name: viewModel.partnerName.isEmpty ? "Người ấy" : viewModel.partnerName,
                birthday: viewModel.partnerBirthday,
                picker: $selectedPartnerPhoto
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardGradient)
                .shadow(color: AppTheme.primaryPink.opacity(0.2), radius: 10, y: 4)
        )
    }

    private func profileAvatar(image: UIImage?, name: String, birthday: Date?, picker: Binding<PhotosPickerItem?>) -> some View {
        VStack(spacing: 8) {
            PhotosPicker(selection: picker, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(AppTheme.softPink)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 34))
                                    .foregroundStyle(AppTheme.roseGold)
                            )
                    }

                    Image(systemName: "camera.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                        .background(Circle().fill(AppTheme.deepRose).padding(-2))
                }
                .shadow(color: AppTheme.primaryPink.opacity(0.3), radius: 6, y: 3)
            }

            Text(name)
                .font(AppTheme.captionFont())
                .foregroundStyle(AppTheme.deepRose)
                .lineLimit(1)
            if let bd = birthday {
                let z = DateCalculator.zodiacSign(for: bd)
                Text("\(z.symbol) \(z.name)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.roseGold)
                Text(DateCalculator.formattedDate(bd))
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }


    // MARK: - Counter + Detail (couple photo background)
    private var counterSection: some View {
        ZStack(alignment: .bottomTrailing) {
            // Background
            Group {
                if let img = viewModel.couplePhoto {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    AppTheme.heroGradient
                }
            }
            .frame(height: 230)
            .clipped()
            .overlay(Color.black.opacity(viewModel.couplePhoto != nil ? 0.38 : 0.15))

            // Content
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 4) {
                    Text("\(viewModel.diff.totalDays)")
                        .font(AppTheme.counterFont(size: 80))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                        .contentTransition(.numericText(countsDown: false))
                        .animation(.easeInOut(duration: 0.4), value: viewModel.diff.totalDays)
                    Text("ngày yêu nhau")
                        .font(AppTheme.headlineFont())
                        .foregroundStyle(.white.opacity(0.92))
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                }
                Spacer()
                // Time row
                HStack(spacing: 0) {
                    compactUnit(value: viewModel.diff.years,   label: "năm")
                    compactUnit(value: viewModel.diff.months,  label: "tháng")
                    compactUnit(value: viewModel.diff.days,    label: "ngày")
                    Rectangle().fill(.white.opacity(0.3)).frame(width: 1, height: 24)
                    compactUnit(value: viewModel.diff.hours,   label: "giờ")
                    compactUnit(value: viewModel.diff.minutes, label: "phút")
                    compactUnit(value: viewModel.diff.seconds, label: "giây")
                }
                .padding(.vertical, 10)
                .background(.black.opacity(0.25))
            }
            .frame(height: 230)

        }
        .frame(height: 230)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .shadow(color: AppTheme.primaryPink.opacity(0.35), radius: 12, y: 6)
    }

    private var detailSection: some View { EmptyView() }

    private func compactUnit(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: value)
                .frame(minWidth: 26)
            Text(label)
                .font(.system(size: 9, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Floating Hearts
    private var floatingHeartsLayer: some View {
        ZStack {
            ForEach(floatingHearts) { heart in
                Text("❤️")
                    .font(.system(size: heart.size))
                    .position(heart.position)
                    .opacity(heart.opacity)
                    .scaleEffect(heart.scale)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func spawnHearts() {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        for _ in 0..<6 {
            let id = UUID()
            let x = CGFloat.random(in: 60...(w - 60))
            let heart = FloatingHeart(id: id, position: CGPoint(x: x, y: h * 0.75),
                                      size: CGFloat.random(in: 18...32), opacity: 0.9, scale: 1.0)
            floatingHearts.append(heart)
            withAnimation(.easeOut(duration: 1.2)) {
                if let idx = floatingHearts.firstIndex(where: { $0.id == id }) {
                    floatingHearts[idx] = FloatingHeart(
                        id: id,
                        position: CGPoint(x: x + CGFloat.random(in: -40...40),
                                          y: h * 0.75 - CGFloat.random(in: 180...300)),
                        size: heart.size, opacity: 0, scale: 0.3)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                floatingHearts.removeAll { $0.id == id }
            }
        }
    }
}

struct FloatingHeart: Identifiable {
    let id: UUID
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
    var scale: CGFloat
}
