import { createHashRouter, RouterProvider } from 'react-router'
import LegacyApp from './LegacyApp'

// Hash routes do not require rewrite rules on shared hosting. The complete client app
// is shipped as static files; PHP endpoints continue to live under ./api/.
const router = createHashRouter([{ path: '*', Component: LegacyApp }])

export default function App() {
  return <RouterProvider router={router} />
}
