import { useIsAuthenticated } from "@azure/msal-react";
import { useMsal } from "@azure/msal-react";

const SignInSignOutButton = () => {
    const { instance, accounts } = useMsal();

    const isAuthenticated = useIsAuthenticated();
    const signInWithPopup = () => {
        instance.loginPopup();
    }
    const signOutWithPopup = () => {
        instance.logoutPopup();
    }
    if (isAuthenticated) {
        return (<div>
            <b>{accounts[0].username}</b><button onClick={signOutWithPopup}>Sign Out</button>
            <pre style={{ "display": "none" }}>{JSON.stringify(accounts, null, 2)}</pre>
        </div>);
    } else {
        return (<div>
            <button onClick={signInWithPopup}>Sign In</button>
        </div>);
    }
}

export default SignInSignOutButton;