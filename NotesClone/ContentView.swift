//
//  ContentView.swift
//  NotesClone
//
//  Created by Артемий Андреев  on 15.03.2025.
//

import SwiftUI

// MARK: - Модель данных

struct Note: Identifiable, Equatable {
    let id: UUID
    var title: String
    var text: String
    
    init(id: UUID = UUID(), title: String, text: String) {
        self.id = id
        self.title = title
        self.text = text
    }
}

// MARK: - ViewModel

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = [
        Note(title: "Уважаемый тимлид", text: "Пожалуйста,ы возьмите меня в команду, может я пока глупенький (silly), но я буду стараться шутить (иногда хорошо) и писать код (иногда не очень хорошо)")
    ]
    
    func addNote(title: String, text: String) {
        let newNote = Note(title: title, text: text)
        notes.append(newNote)
    }
    
    func deleteNote(_ note: Note) {
        if let index = notes.firstIndex(of: note) {
            notes.remove(at: index)
        }
    }
    
    func updateNote(_ note: Note, title: String, text: String) {
        if let index = notes.firstIndex(of: note) {
            notes[index].title = title
            notes[index].text = text
        }
    }
}

// MARK: - Список заметок

struct NotesListView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    @State private var showingAddNote = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.notes) { note in
                    NavigationLink(destination: NoteDetailView(note: note)) {
                        Text(note.title)
                            .lineLimit(1)
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { viewModel.notes[$0] }.forEach { note in
                        viewModel.deleteNote(note)
                    }
                }
            }
            .navigationTitle("Мои заметки")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                NoteDetailView(isNewNote: true)
            }
        }
    }
}

// MARK: - Экран редактирования / создания заметки

struct NoteDetailView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    
    var note: Note?
    var isNewNote: Bool
    
    @State private var title: String
    @State private var text: String
    
    @State private var isDeleted: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    init(note: Note? = nil, isNewNote: Bool = false) {
        self.note = note
        self.isNewNote = isNewNote
        
        _title = State(initialValue: note?.title ?? "")
        _text = State(initialValue: note?.text ?? "")
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Заголовок", text: $title)
                    .font(.title2)
                    .padding()
                
                Divider()
                
                TextEditor(text: $text)
                    .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        if let note = note {
                            viewModel.deleteNote(note)
                        }
                        isDeleted = true
                        dismiss()
                    } label: {
                        Text("Удалить")
                    }
                }
            }
            .onDisappear {
                guard !isDeleted else { return }
                
                if let note = note {
                    viewModel.updateNote(note, title: title, text: text)
                } else {
                    if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.addNote(title: title, text: text)
                    }
                }
            }
        }
    }
}

// MARK: - Точка входа в приложение

@main
struct NotesApp: App {
    @StateObject private var viewModel = NotesViewModel()
    
    var body: some Scene {
        WindowGroup {
            NotesListView()
                .environmentObject(viewModel)
        }
    }
}
