import React from 'react';
import { InteractionRequiredAuthError } from "@azure/msal-browser"
import { useMsal } from "@azure/msal-react";
import { loginRequest } from './authConfig'

import axios from 'axios';
import Linklistitem from  './Linklistitem'




const Linklist = () => {
    const { instance, accounts } = useMsal()

    const getTokenPopup = (request) => {

        /**
        * See here for more information on account retrieval: 
        * https://github.com/AzureAD/microsoft-authentication-library-for-js/blob/dev/lib/msal-common/docs/Accounts.md
        */
        request.account = instance.getAccountByHomeId(accounts[0].homeAccountId);


        /**
         * 
         */
        return instance.acquireTokenSilent(request)
            .then((response) => {
                // In case the response from B2C server has an empty accessToken field
                // throw an error to initiate token acquisition
                if (!response.accessToken || response.accessToken === "") {
                    throw new InteractionRequiredAuthError();
                }
                return response;
            })
            .catch(error => {
                console.log("Silent token acquisition fails. Acquiring token using popup. \n", error);
                if (error instanceof InteractionRequiredAuthError) {
                    // fallback to interaction when silent call fails
                    return instance.acquireTokenPopup(request)
                        .then(response => {
                            //console.log(response);
                            return response;
                        }).catch(error => {
                            console.log(error);
                        });
                } else {
                    console.log(error);
                }
            });
    }

    const loadLinks = () => {
        getTokenPopup(loginRequest).then(response => {
            if (response) {
                console.log("access_token acquired at: " + new Date().toString());
                try {
                    
                    //console.log(response)
                    const bearer = `Bearer ${response.idToken}`;

                    // const headers = new Headers();
                    // headers.append("Authorization", bearer);
                
                    // const options = {
                    //     method: "GET",
                    //     headers: headers,
                    //     //mode: 'no-cors',
                    //   };
                    axios.get('https://linklist-func.scallighan.com/api/links', { 
                        headers: { 
                            Authorization: bearer 
                        },  
                        withCredentials : true 
                    }).then(response => {
                        console.log('hellolinklist')
                        console.log(response.data)
                        setLinklist(response.data)
                    })
                } catch (error) {
                    console.log(error);
                }
            }
        })
    }

    const [linklist, setLinklist] = React.useState([]);

    React.useEffect(() => {
        loadLinks()
        // eslint-disable-next-line
      }, []);

    
    console.log(linklist)
    return (<div>
        
        { (!Array.isArray(linklist)) ? <div>{linklist}</div> : linklist.map((link,index)=>{
         return <Linklistitem key={index} item={link}></Linklistitem>
        }) }
        <button onClick={loadLinks}>Do Stuff!</button>
    </div>)
}

export default Linklist;