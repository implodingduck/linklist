import './App.css';
import { MsalProvider } from "@azure/msal-react";
import { AuthenticatedTemplate, UnauthenticatedTemplate } from "@azure/msal-react";
import SignInSignOutButton from './SignInSignOutButton';
import Linklist from './Linklist';

function App({ pca }) {

  return (
    <MsalProvider instance={pca}>
      <SignInSignOutButton></SignInSignOutButton>
      <AuthenticatedTemplate>
        <div>
            <Linklist></Linklist>
        </div>
      </AuthenticatedTemplate>
      <UnauthenticatedTemplate>
        <p>Please Sign In</p>
      </UnauthenticatedTemplate>
    </MsalProvider>
  );
}

export default App;
