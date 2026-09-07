import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import Login from '@/views/Login.vue'

const mockLogin = vi.fn()

vi.mock('@/services/authService', () => ({
  authService: {
    login: mockLogin,
  },
}))

const router = createRouter({
  history: createMemoryHistory(),
  routes: [
    { path: '/', redirect: '/login' },
    { path: '/login', component: Login },
    { path: '/dashboard', component: { template: '<div>Dashboard</div>' } },
  ],
})

describe('Login.vue', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    router.push('/login')
  })

  it('LG-01: should render login form', async () => {
    const wrapper = mount(Login, {
      global: {
        plugins: [router],
      },
    })
    await router.isReady()

    expect(wrapper.find('[data-testid="email-input"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="password-input"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="login-button"]').exists()).toBe(true)
  })

  it('LG-02: should show error on failed login', async () => {
    mockLogin.mockResolvedValue({ success: false, error: 'Identifiants invalides' })

    const wrapper = mount(Login, {
      global: {
        plugins: [router],
      },
    })
    await router.isReady()

    await wrapper.find('[data-testid="email-input"]').setValue('wronguser')
    await wrapper.find('[data-testid="password-input"]').setValue('wrongpass')
    await wrapper.find('form').trigger('submit.prevent')
    await flushPromises()

    expect(wrapper.find('[data-testid="error-message"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="error-message"]').text()).toContain('Identifiants invalides')
  })

  it('LG-03: should call authService on successful login', async () => {
    mockLogin.mockResolvedValue({ success: true })

    const wrapper = mount(Login, {
      global: {
        plugins: [router],
      },
    })
    await router.isReady()

    await wrapper.find('[data-testid="email-input"]').setValue('admin')
    await wrapper.find('[data-testid="password-input"]').setValue('password')
    await wrapper.find('form').trigger('submit.prevent')
    await flushPromises()

    expect(mockLogin).toHaveBeenCalledWith('admin', 'password')
  })
})
