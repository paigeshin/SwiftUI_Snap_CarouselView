//
//  ContentView.swift
//  SwiftUICarousel
//
//  Created by paige on 2022/03/31.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            
            Color
                .white
                .ignoresSafeArea()
            
            Home()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

struct Home: View {
    
    @State var currentIndex: Int = 0
    @State var posts: [Post] = []
    @State var currentTab = "Slide Show"
    @Namespace var animation
    
    var body: some View {
        VStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 12) {
                Button {
                    
                } label: {
                    Label {
                        Text("Back")
                    } icon: {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                    }
                    .foregroundColor(.primary)
                } //: BUTTON
                
                Text("My Wishes")
                    .font(.title)
                    .fontWeight(.bold)
                
            } //: VSTACK - INNER
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            // MARK: : SEGMENT CONTROL
            HStack(spacing: 0) {
                TabButton(title: "Slide Show",
                          animation: animation,
                          currentTab: $currentTab)
                TabButton(title: "List",
                          animation: animation,
                          currentTab: $currentTab)
            }
            .padding(.horizontal)
            .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
            
            // MARK: SNAP CAROUSEL
            SnapCarousel(
                index: $currentIndex,
                items: posts) { post in
                    
                    GeometryReader { proxy in
                        
                        let size: CGSize = proxy.size
                        
                        Image(post.postImage) //: IMAGE
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width)
                            .cornerRadius(12)
                        
                    } //: GEOMTERY READER
                    
                } //: SNAP CAORUSEL
                .padding(.vertical, 40)
            
            // MARK: INDICATOR
            HStack(spacing: 10) {
                ForEach(posts.indices, id: \.self) { index in
                    Circle()
                        .fill(Color.black.opacity(currentIndex == index ? 1 : 0.1))
                        .frame(width: 10, height: 10)
                        .scaleEffect(currentIndex == index ? 1.4 : 1)
                        .animation(.spring(), value: currentIndex == index)
                }
            }
            .padding(.bottom, 40)
            
            
        } //: VSTACK - OUTER
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            for index in 0...5 {
                posts.append(Post(postImage: "dogdogdog"))
                print("Loop: \(index)")
            }
        }
        
        
    }
}

struct TabButton: View {
    
    var title: String
    var animation: Namespace.ID
    @Binding var currentTab: String
    
    var body: some View {
        
        Button {
            withAnimation(.spring()) {
                currentTab = title
            }
        } label: {
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(currentTab == title ? .white : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        if currentTab == title {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.black)
                                .matchedGeometryEffect(id: "id", in: animation)
                        }
                    }
                )
        }
        
    }
    
}


struct SnapCarousel<Content: View, T: Identifiable>: View {
    
    var content: (T) -> Content
    var list: [T]
    
    // Properties
    var spacing: CGFloat
    var trailingSpace: CGFloat
    @Binding var index: Int
    
    // Offset
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
    
    init(
        spacing: CGFloat = 15,
        trailingSpace: CGFloat = 100,
        index: Binding<Int>,
        items: [T],
        @ViewBuilder content: @escaping(T) -> Content
    ) {
        self.list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.content = content
    }
    
    var body: some View {
        GeometryReader { proxy in
            
            // Setting correct width for snap carousel....
            
            // One Sided Snap Carousel...
            let width: CGFloat = proxy.size.width - (trailingSpace - spacing)
            let adjustmentWidth = (trailingSpace / 2) - spacing
            
            HStack(spacing: spacing) {
                ForEach(list) { item in
                    content(item)
                        .frame(width: proxy.size.width - trailingSpace)
                } //: FOREACH
            } //: HSTACK
            // Spacing will be horizontal padding...
            .padding(.horizontal, spacing)
            // settig only after 0th index...
            .offset(x: (CGFloat(currentIndex) * -width)
                    + (currentIndex != 0 ? adjustmentWidth : 0)
                    + offset)
            .gesture(
                DragGesture()
                    .updating($offset) { value, output, _ in
                        output = value.translation.width
                    }
                    .onEnded { value in
                        
                        // Updating Current Index
                        let offsetX: CGFloat = value.translation.width
                        
                        // going to convert the translation into progress
                        // and round the value...
                        // based on the progress increasing or decreasing the currentIndex...
                        
                        let progress: CGFloat = -offsetX / width
                        let roundIndex: CGFloat = progress.rounded()
                        
                        currentIndex += max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                        
                        // updating index...
                        currentIndex = index
                    }
                    .onChanged({ value in
                        // updating only index...
                        // Updating Current Index
                        let offsetX: CGFloat = value.translation.width
                        
                        // going to convert the translation into progress
                        // and round the value...
                        // based on the progress increasing or decreasing the currentIndex...
                        
                        let progress: CGFloat = -offsetX / width
                        let roundIndex: CGFloat = progress.rounded()
                        
                        index = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                    })
            )
        } // GEOMETRY READER
        // Animationg when offset = 0
        .animation(.easeInOut, value: offset == 0)
    }
    
    
}


struct Post: Identifiable {
    var id = UUID().uuidString
    var postImage: String
}
