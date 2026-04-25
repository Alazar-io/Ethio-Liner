'use client'

import { createContext, useContext, useState, type ReactNode } from 'react'
import type { User, ChatMessage, Prescription, MedicalHistoryItem } from './types'

interface AppContextType {
  user: User | null
  isLoggedIn: boolean
  login: (user: User) => void
  logout: () => void
  updateUser: (updates: Partial<User>) => void
  addPrescription: (prescription: Omit<Prescription, 'id' | 'prescribedDate'>) => void
  chatMessages: ChatMessage[]
  addChatMessage: (message: Omit<ChatMessage, 'id' | 'timestamp'>) => void
  clearChat: () => void
}

const AppContext = createContext<AppContextType | undefined>(undefined)

export function AppProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [chatMessages, setChatMessages] = useState<ChatMessage[]>([])

  const isLoggedIn = user !== null

  const login = (newUser: User) => {
    setUser(newUser)
  }

  const logout = () => {
    setUser(null)
    setChatMessages([])
  }

  const updateUser = (updates: Partial<User>) => {
    if (user) {
      setUser({ ...user, ...updates })
    }
  }

  const addPrescription = (prescription: Omit<Prescription, 'id' | 'prescribedDate'>) => {
    if (!user) return

    const newPrescription: Prescription = {
      ...prescription,
      id: Date.now().toString(),
      prescribedDate: new Date().toISOString().split('T')[0],
    }

    setUser({
      ...user,
      prescriptions: [...user.prescriptions, newPrescription],
    })
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
        user,
        isLoggedIn,
        login,
        logout,
        updateUser,
        addPrescription,
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
