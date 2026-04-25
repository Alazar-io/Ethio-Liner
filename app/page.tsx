'use client'

import { useState } from 'react'
import { AppProvider, useApp } from '@/lib/app-context'
import { LoginScreen } from '@/components/login-screen'
import { SidebarNavigation, type Page } from '@/components/sidebar-navigation'
import { Dashboard } from '@/components/dashboard'
import { PrescriptionScanner } from '@/components/prescription-scanner'
import { EmergencyPanel } from '@/components/emergency-panel'
import { ChatInterface } from '@/components/chat-interface'
import { HealthCard } from '@/components/health-card'

function MedbridgeApp() {
  const { isLoggedIn, login, logout } = useApp()
  const [currentPage, setCurrentPage] = useState<Page>('dashboard')

  if (!isLoggedIn) {
    return <LoginScreen onLogin={login} />
  }

  const handleNavigate = (page: Page) => {
    setCurrentPage(page)
  }

  return (
    <div className="flex min-h-screen bg-background">
      <SidebarNavigation
        currentPage={currentPage}
        onPageChange={setCurrentPage}
        onLogout={logout}
      />
      <main className="flex-1 overflow-auto">
        <div className="container mx-auto max-w-6xl px-6 py-8">
          {currentPage === 'dashboard' && <Dashboard onNavigate={handleNavigate} />}
          {currentPage === 'health-card' && <HealthCard />}
          {currentPage === 'prescriptions' && <PrescriptionScanner />}
          {currentPage === 'emergency' && <EmergencyPanel />}
          {currentPage === 'chat' && <ChatInterface />}
        </div>
      </main>
    </div>
  )
}

export default function Page() {
  return (
    <AppProvider>
      <MedbridgeApp />
    </AppProvider>
  )
}
