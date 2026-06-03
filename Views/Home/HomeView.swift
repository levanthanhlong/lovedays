import SwiftUI
import PhotosUI

struct HomeView: View {
    @ObservedObject var viewModel: LoveViewModel
    @State private var selectedMyPhoto: PhotosPickerItem?
    @State private var selectedPartnerPhoto: PhotosPickerItem?
    @State private var floatingHearts: [FloatingHeart] = []
    @State private var showPinkOverlay = false

    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()

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

            // Pink tint overlay (above scroll, below hearts)
            Color(red: 1.0, green: 0.72, blue: 0.82)
                .opacity(showPinkOverlay ? 0.22 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeInOut(duration: 0.35), value: showPinkOverlay)

            // Hearts layer on top of everything
            floatingHeartsLayer
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
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
                    .scaleEffect(viewModel.heartAnimating ? 1.4 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.4), value: viewModel.heartAnimating)
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
                Image(systemName: "heart.fill")
                    .font(.system(size: heart.size))
                    .foregroundStyle(.red)
                    .shadow(color: .red.opacity(0.4), radius: 4, y: 2)
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

        // Show pink tint
        withAnimation { showPinkOverlay = true }

        for i in 0..<18 {
            let id = UUID()
            let delay = Double(i) * 0.07
            let x = CGFloat.random(in: 20...(w - 20))
            let startY = h + CGFloat.random(in: 0...60)
            let duration = Double.random(in: 1.6...2.4)
            let heart = FloatingHeart(
                id: id,
                position: CGPoint(x: x, y: startY),
                size: CGFloat.random(in: 18...48),
                opacity: Double.random(in: 0.75...1.0),
                scale: 1.0
            )
            floatingHearts.append(heart)

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: duration)) {
                    if let idx = floatingHearts.firstIndex(where: { $0.id == id }) {
                        floatingHearts[idx] = FloatingHeart(
                            id: id,
                            position: CGPoint(
                                x: x + CGFloat.random(in: -50...50),
                                y: CGFloat.random(in: -80...80)
                            ),
                            size: heart.size, opacity: 0,
                            scale: CGFloat.random(in: 0.4...1.2)
                        )
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    floatingHearts.removeAll { $0.id == id }
                }
            }
        }

        // Hide pink tint
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeOut(duration: 0.6)) { showPinkOverlay = false }
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
