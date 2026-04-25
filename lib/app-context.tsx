'use client'

import { createContext, useContext, useState, type ReactNode } from 'react'
import type { Role, Patient, ChatMessage, Note, Prescription } from './types'
import { patients as initialPatients } from './mock-data'

interface AppContextType {
  isLoggedIn: boolean
  login: (role: Role) => void
  logout: () => void
  role: Role
  setRole: (role: Role) => void
  selectedPatientId: string
  setSelectedPatientId: (id: string) => void
  patients: Patient[]
  selectedPatient: Patient | undefined
  addNote: (content: string) => void
  addPrescription: (prescription: Omit<Prescription, 'id' | 'prescribedDate' | 'prescribedBy'>) => void
  updatePatientField: (field: keyof Patient, value: unknown) => void
  chatMessages: ChatMessage[]
  addChatMessage: (message: Omit<ChatMessage, 'id' | 'timestamp'>) => void
  clearChat: () => void
}

const AppContext = createContext<AppContextType | undefined>(undefined)

export function AppProvider({ children }: { children: ReactNode }) {
  const [isLoggedIn, setIsLoggedIn] = useState(false)
  const [role, setRole] = useState<Role>('patient')
  const [selectedPatientId, setSelectedPatientId] = useState(initialPatients[0].id)
  const [patients, setPatients] = useState<Patient[]>(initialPatients)
  const [chatMessages, setChatMessages] = useState<ChatMessage[]>([])

  const selectedPatient = patients.find((p) => p.id === selectedPatientId)

  const login = (selectedRole: Role) => {
    setRole(selectedRole)
    setIsLoggedIn(true)
  }

  const logout = () => {
    setIsLoggedIn(false)
    setRole('patient')
    setChatMessages([])
  }

  const addNote = (content: string) => {
    if (!selectedPatient || role !== 'doctor') return

    const newNote: Note = {
      id: Date.now().toString(),
      date: new Date().toISOString().split('T')[0],
      content,
      author: selectedPatient.doctor,
    }

    setPatients((prev) =>
      prev.map((p) =>
        p.id === selectedPatientId ? { ...p, notes: [...p.notes, newNote] } : p
      )
    )
  }

  const addPrescription = (prescription: Omit<Prescription, 'id' | 'prescribedDate' | 'prescribedBy'>) => {
    if (!selectedPatient || role !== 'doctor') return

    const newPrescription: Prescription = {
      ...prescription,
      id: Date.now().toString(),
      prescribedDate: new Date().toISOString().split('T')[0],
      prescribedBy: selectedPatient.doctor,
    }

    setPatients((prev) =>
      prev.map((p) =>
        p.id === selectedPatientId
          ? { ...p, prescriptions: [...p.prescriptions, newPrescription] }
          : p
      )
    )
  }

  const updatePatientField = (field: keyof Patient, value: unknown) => {
    if (role !== 'doctor') return

    setPatients((prev) =>
      prev.map((p) =>
        p.id === selectedPatientId ? { ...p, [field]: value } : p
      )
    )
  }

  const addChatMessage = (message: Omit<ChatMessage, 'id' | 'timestamp'>) => {
    const newMessage: ChatMessage = {
      ...message,
      id: Date.now().toString(),
      timestamp: new Date(),
    }
    setChatMessages((prev) => [...prev, newMessage])
  }

  const clearChat = () => setChatMessages([])

  return (
    <AppContext.Provider
      value={{
        isLoggedIn,
        login,
        logout,
        role,
        setRole,
        selectedPatientId,
        setSelectedPatientId,
        patients,
        selectedPatient,
        addNote,
        addPrescription,
        updatePatientField,
        chatMessages,
        addChatMessage,
        clearChat,
      }}
    >
      {children}
    </AppContext.Provider>
  )
}

export function useApp() {
  const context = useContext(AppContext)
  if (!context) {
    throw new Error('useApp must be used within an AppProvider')
  }
  return context
}
