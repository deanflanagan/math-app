#!/bin/bash

set -e

npm_config_yes=true npx create-react-app frontend 
cd frontend

npm install tailwindcss axios @tailwindcss/forms flowbite flowbite-react react-toastify react-router-dom

cat <<EOF > src/App.js
// App.js

import { BrowserRouter, Route, Routes } from "react-router-dom";
import "./App.css";
import AppNavBar from "./components/AppNavBar";
import Login from "./pages/Login";
import Register from "./pages/Register";
import Home from "./pages/Home";
import ForgotPassword from "./pages/ForgotPassword";
import { ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import ResetPassword from "./pages/ResetPassword";
import Profile from "./pages/Profile";
import { useState } from "react";

const App = () => {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");

  return (
    <div className="md:h-screen bg-purple-100">
      <BrowserRouter>
        <ToastContainer />
        <AppNavBar
          isLoggedIn={isLoggedIn}
          setIsLoggedIn={setIsLoggedIn}
          name={name}
          setName={setName}
          email={email}
          setEmail={setEmail}
        />
        <div>
          <Routes>
            <Route path="/" exact
              element={
                <Home isLoggedIn={isLoggedIn} setIsLoggedIn={setIsLoggedIn} />
              }
            />
            <Route path="register" exact
              element={
                <Register
                  isLoggedIn={isLoggedIn}
                  setIsLoggedIn={setIsLoggedIn}
                  setName={setName}
                  setEmail={setEmail}
                />
              }
            />
            <Route path="login" exact
              element={
                <Login
                  isLoggedIn={isLoggedIn}
                  setIsLoggedIn={setIsLoggedIn}
                  setName={setName}
                  setEmail={setEmail}
                />
              }
            />
            <Route path="forgotPassword" exact
              element={<ForgotPassword isLoggedIn={isLoggedIn} />}
            />
            <Route path="resetPassword" 
              element={<ResetPassword isLoggedIn={isLoggedIn} />}
            />
            <Route path="profile" exact
              element={
                <Profile isLoggedIn={isLoggedIn} name={name} email={email} />
              }
            />
          </Routes>
        </div>
      </BrowserRouter>
    </div>
  );
};

export default App;
EOF

cat <<EOF > src/index.css
@import 'tailwindcss/base';
@import 'tailwindcss/components';
@import 'tailwindcss/utilities';

.required:after {
  content: " *";
  color: red;
}
EOF

cat <<EOF > tailwind.config.js
// tailwind.config.js

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
    "node_modules/flowbite-react/lib/esm/**/*.js",
    "./node_modules/flowbite/**/*.js"
  ],
  theme: {
    extend: {},
  },
  plugins: [require("@tailwindcss/forms"), require("flowbite/plugin")],
};
EOF

mkdir -p src/components src/pages

cat <<EOF > src/components/AppNavBar.js
// components/AppNavbar.js

import { Avatar, Dropdown, Navbar } from "flowbite-react";
import UserIcon from "../images/user.png";
import { toast } from "react-toastify";
import { useNavigate } from "react-router-dom";

const AppNavBar = (props) => {
  let navigate = useNavigate();

  const { isLoggedIn, setIsLoggedIn, name, setName, email, setEmail } = props;

  const handleLogout = () => {
    setIsLoggedIn(false);
    setName(null);
    setEmail(null);
    navigate("/");
    toast.success("You are successfully logged out!");
  };

  return (
    <Navbar fluid>
      <Navbar.Brand href="https://github.com/deanflanagan">
        <img
          src="https://media.geeksforgeeks.org/wp-content/uploads/20210224040124/JSBinCollaborativeJavaScriptDebugging6-300x160.png"
          className="mr-3 h-6 sm:h-9"
          alt="Flowbite React Logo"
        />
        <span className="self-center whitespace-nowrap text-3xl font-semibold dark:text-white">GeeksForGeeks</span>
      </Navbar.Brand>
      {isLoggedIn && (
        <div className="flex md:order-2">
          <Dropdown arrowIcon={false} inline
            label={<Avatar alt="User settings" img={UserIcon} rounded />}>
            <Dropdown.Header>
              <span className="block text-sm">{name}</span>
              <span className="block truncate text-sm font-medium">{email}</span>
            </Dropdown.Header>
            <Dropdown.Item>Settings</Dropdown.Item>
            <Dropdown.Item>Your Orders</Dropdown.Item>
            <Dropdown.Divider />
            <Dropdown.Item onClick={handleLogout}>Log out</Dropdown.Item>
          </Dropdown>
          <Navbar.Toggle />
        </div>
      )}
      <Navbar.Collapse>
        <Navbar.Link href="/" className="text-lg">Home</Navbar.Link>
        <Navbar.Link href="#" className="text-lg">About</Navbar.Link>
        <Navbar.Link href="#" className="text-lg">Services</Navbar.Link>
        <Navbar.Link href="#" className="text-lg">Pricing</Navbar.Link>
        <Navbar.Link href="#" className="text-lg">Contact</Navbar.Link>
        {!isLoggedIn && (
          <Navbar.Link href="/login" className="text-lg">Login</Navbar.Link>
        )}
      </Navbar.Collapse>
    </Navbar>
  );
};

export default AppNavBar;
EOF

cat <<EOF > src/components/CountryInput.js
// component/CountryInput.js

const countries = [
  "Select Country",
  "India",
  "United States",
  "Japan",
  "Australia",
  "Canada",
];

const CountryInput = () => {
  return (
    <div className="max-w-xl">
      <div className="mb-2 block">
        <label htmlFor="country" className="text-sm font-medium required">
          Country
        </label>
      </div>
      <select
        id="country"
        name="country"
        class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-purple-500 focus:border-purple-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-purple-500 dark:focus:border-purple-500"
        required
      >
        {countries.map((el, index) => (
          <option key={index}>{el}</option>
        ))}
      </select>
    </div>
  );
};

export default CountryInput;
EOF

echo "REACT_APP_BACKEND_URL=http://localhost:8000" > .env

cat <<EOF > src/pages/Home.js
// pages/Home.js

const Home = () => {
  return (
    <div>
      <h2 className="font-bold my-5 text-xl text-center">This is simple home page. Customize as per your usecase</h2>
    </div>
  );
};

export default Home;
EOF

cat <<EOF > src/pages/Login.js
// pages/Login.js

import { useNavigate } from "react-router-dom";
import axios from "axios";
import { toast } from "react-toastify";
import { useEffect } from "react";

const URL = process.env.REACT_APP_BACKEND_URL + "/api/login";

const Login = (props) => {
  let navigate = useNavigate();
  const { isLoggedIn, setIsLoggedIn, setName, setEmail } = props;

  useEffect(() => {
    if (isLoggedIn) navigate("profile");
  });

  const handleLogin = async (ev) => {
    ev.preventDefault();
    const email = ev.target.email.value;
    const password = ev.target.password.value;
    const formData = { email: email, password: password };
    const res = await axios.post(URL, formData);
    const data = res.data;
    if (data.success === true) {
      toast.success(data.message);
      setIsLoggedIn(true);
      setEmail(email);
      navigate("/profile");
    } else toast.error(data.message);
  };

  return (
    <div className="w-full flex justify-center my-4">
      <div className="w-full max-w-lg p-6 bg-white border border-gray-200 rounded-lg shadow dark:bg-gray-800 dark:border-gray-700">
        <h5 className="text-2xl font-bold tracking-tight text-gray-900 dark:text-white text-center">
          Login to your account
        </h5>
        <form
          className="w-full flex max-w-md flex-col gap-4"
          onSubmit={handleLogin}
        >
          <div>
            <div className="mb-2 block">
              <label htmlFor="email" className="text-sm font-medium required">
                Email
              </label>
            </div>
            <input
              id="email"
              type="email"
              placeholder="Your Email"
              class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-purple-500 focus:border-purple-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-purple-500 dark:focus:border-purple-500"
              required
            />
          </div>
          <div>
            <div className="flex items-center justify-between mb-2 block">
              <label
                htmlFor="password"
                className="text-sm font-medium required"
              >
                Password
              </label>
              <div className="text-sm">
                <a
                  href="forgotPassword"
                  className="font-semibold text-purple-600 hover:text-purple-500"
                >
                  Forgot password?
                </a>
              </div>
            </div>
            <input
              id="password"
              type="password"
              placeholder="Your Password"
              class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-purple-500 focus:border-purple-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-purple-500 dark:focus:border-purple-500"
              required
            />
          </div>
          <div className="flex items-center gap-2 mb-2">
            <input
              type="checkbox"
              id="remember"
              class="w-4 h-4 text-purple-600 bg-gray-100 border-gray-300 rounded focus:ring-purple-500 dark:focus:ring-purple-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
            />
            <label htmlFor="remember" className="text-sm font-medium">
              Remember me
            </label>
          </div>
          
          <button
            type="submit"
            class="focus:outline-none text-white bg-purple-600 hover:bg-purple-700 focus:ring-4 focus:ring-purple-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-purple-500 dark:hover:bg-purple-600 dark:focus:ring-purple-800"
          >
            Submit
          </button>

          <p className="text-center text-sm text-gray-500">
            Not yet registered?{" "}
            <a
              href="register"
              className="font-semibold leading-6 text-purple-600 hover:text-purple-500"
            >
              Register Here
            </a>
          </p>
        </form>
      </div>
    </div>
  );
};

export default Login;
EOF

cat <<EOF > src/pages/Register.js
// pages/Register.js

import { useNavigate } from "react-router-dom";
import axios from "axios";
import { toast } from "react-toastify";
import CountryInput from "../components/CountryInput";
import { useEffect } from "react";

const URL = process.env.REACT_APP_BACKEND_URL + "/api/register";
const Register = (props) => {
  const { isLoggedIn, setIsLoggedIn, setName, setEmail } = props;
  let navigate = useNavigate();

  useEffect(() => {
    if (isLoggedIn) navigate("profile");
  });

  const handleRegister = async (ev) => {
    ev.preventDefault();
    const name = ev.target.name.value;
    const email = ev.target.email.value;
    const password = ev.target.password.value;
    const confirmpassword = ev.target.confirmpassword.value;
    const country = ev.target.country.value;
    const phone = ev.target.phone.value;
    if (country === "Select Country") toast.error("Select your country !");
    if (password !== confirmpassword) toast.error("Passwords do not match !");
    else{
      const formData = {
        name: name,
        email: email,
        password: password,
        country: country,
        phone: phone,
      };
      try {
        const res = await axios.post(URL, formData);
        const data = res.data;
        if (data.success === true) {
          toast.success(data.message);
          setIsLoggedIn(true);
          setName(name);
          setEmail(email);
          navigate("/profile");
        } else {
          toast.error(data.message);
        }
      } catch (err) {
        console.log("Some error occured", err);
      }
    }
  };

  return (
    <div className="w-full flex flex-col items-center justify-center px-6 py-8 mx-auto my-5 lg:py-0">
      <div className="w-full bg-white rounded-lg shadow dark:border md:mt-0 sm:max-w-xl xl:p-0 dark:bg-gray-800 dark:border-gray-700">
        <div className="p-6 space-y-4 md:space-y-6 sm:p-8">
          <h1 className="text-xl font-bold leading-tight tracking-tight text-gray-900 md:text-2xl dark:text-white text-center">
            Create an account
          </h1>
          <form
            className="space-y-4 md:space-y-"
            action="POST"
            onSubmit={handleRegister}
          >
            <div>
              <div className="mb-2 block">
                <label htmlFor="name" className="text-sm font-medium required">
                  Name
                </label>
              </div>
              <input
                id="name"
                name="name"
                type="text"
                placeholder="Your Name"
                className="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-purple-500 focus:border-purple-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-purple-500 dark:focus:border-purple-500"
                required
              />
            </div>

            <div>
              <div className="mb-2 block">
                <label htmlFor="email" className="text-sm font-medium required">
                  Email
                </label>
              </div>
              <input
                type="email"
                name="email"
                id="email"
                className="bg-gray-50 border border-gray-300 text-gray-900 sm:text-sm rounded-lg focus:ring-purple-600 focus:border-purple-600 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-purple-500 dark:focus:border-purple-500"
                placeholder="Your Email"
                required
              />
            </div>

            <div class="grid gap-6 mb-6 md:grid-cols-2">
              <div>
                <div className="mb-2 block">
                  <label
                    htmlFor="password"
                    className="text-sm font-medium required"
                  >
                    Password
                  </label>
                </div>
                <input
                  type="password"
                  name="password"
                  id="password"
                  placeholder="Your Password"
                  className="bg-gray-50 border border-gray-300 text-gray-900 sm:text-sm rounded-lg focus:ring-purple-600 focus:border-purple-600 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-purple-500 dark:focus:border-purple-500"
                  required
                />
              </div>
              <div>
                <div className="mb-2 block">
                  <label
                    htmlFor="confirmpassword"
                    className="text-sm font-medium required"
                  >
                    Confirm Password
                  </label>
                </div>
                <input
                  type="password"
                  name="confirmpassword"
                  id="confirmpassword"
                  placeholder="Re-enter Password"
                  className="bg-gray-50 border border-gray-300 text-gray-900 sm:text-sm rounded-lg focus:ring-purple-600 focus:border-purple-600 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-purple-500 dark:focus:border-purple-500"
                  required
                />
              </div>
            </div>

            <CountryInput />
            <div className="max-w-xl">
              <div className="mb-2 block">
                <label htmlFor="phone" className="text-sm font-medium">
                  Phone Number
                </label>
              </div>
              <input
                type="text"
                id="phone"
                name="phone"
                className="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-purple-500 focus:border-purple-500 block w-full dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-purple-500 dark:focus:border-purple-500"
                maxLength={10}
                pattern="^[79][0-9]{9}"
                placeholder="1234567890"
                aria-errormessage="Phone number must start with 7 or 9"
              />
            </div>

            <div className="flex items-start">
              <div className="flex items-center h-5">
                <input
                  id="terms"
                  type="checkbox"
                  class="w-4 h-4 text-purple-600 bg-gray-100 border-gray-300 rounded focus:ring-purple-500 dark:focus:ring-purple-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
                  required
                  aria-describedby="terms"
                />
              </div>
              <div className="ml-3 text-sm">
                <label
                  htmlFor="terms"
                  className="font-light text-gray-500 dark:text-gray-300"
                >
                  I accept the{" "}
                  <a
                    className="font-medium text-purple-600 hover:underline dark:text-purple-500"
                    href="#"
                  >
                    Terms and Conditions
                  </a>
                </label>
              </div>
            </div>

            <button
              type="submit"
              class="w-full focus:outline-none text-white bg-purple-600 hover:bg-purple-700 focus:ring-4 focus:ring-purple-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-purple-500 dark:hover:bg-purple-600 dark:focus:ring-purple-800"
            >
              Create an account
            </button>
            <p className="text-center text-sm text-gray-500">
              Already have an account?{" "}
              <a
                href="login"
                className="font-semibold leading-6 text-purple-600 hover:text-purple-500"
              >
                Login Here
              </a>
            </p>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Register;
EOF

cat <<EOF > src/pages/ForgotPassword.js
// pages/ForgotPassword.js

import axios from "axios";
import { toast } from "react-toastify";

const URL = process.env.REACT_APP_BACKEND_URL + "/api/forgotPassword";

const ForgotPassword = () => {
  const handleSubmit = async (ev) => {
    ev.preventDefault();
    const email = ev.target.email.value;
    const formData = { email: email };
    const res = await axios.post(URL, formData);
    const data = res.data;
    if (data.success === true) toast.success(data.message);
    else toast.error(data.message);
  };

  return (
    <div className="flex justify-center my-4">
      <div className="w-full max-w-lg p-6 bg-white border border-gray-200 rounded-lg shadow dark:bg-gray-800 dark:border-gray-700">
        <h5 className="text-2xl font-bold tracking-tight text-gray-900 dark:text-white text-center">Forgot Password</h5>
        <form className="flex max-w-md flex-col gap-4" onSubmit={handleSubmit}>
          <div>
            <div className="mb-2 block">
              <label htmlFor="email" className="text-sm font-medium required">Email</label>
            </div>
            <input id="email" type="email" name="email" placeholder="Enter your email" required
              class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-purple-500 focus:border-purple-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-purple-500 dark:focus:border-purple-500"
            />
          </div>
          <div className="mt-2 block">
            <button type="submit" class="w-full focus:outline-none text-white bg-purple-600 hover:bg-purple-700 focus:ring-4 focus:ring-purple-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-purple-500 dark:hover:bg-purple-600 dark:focus:ring-purple-800">
              Submit
            </button>
          </div>
          <p className="text-center text-sm text-gray-500">
            Remember your password?{" "}
            <a href="login" className="font-semibold leading-6 text-purple-600 hover:text-purple-500">
              Login Here
            </a>
          </p>
        </form>
      </div>
    </div>
  );
};

export default ForgotPassword;
EOF

cat <<EOF > src/pages/ResetPassword.js
// pages/ResetPassword.js

import { React } from "react";
import axios from "axios";
import { useSearchParams, useNavigate } from "react-router-dom";
import { toast } from "react-toastify";

const URL = process.env.REACT_APP_BACKEND_URL + "/api/resetPassword";

const ResetPassword = () => {
  const [searchParams] = useSearchParams();
  let navigate = useNavigate();
  const id = searchParams.get("id");
  const token = searchParams.get("token");

  const handleResetPassword = async (ev) => {
    ev.preventDefault();
    const newpassword = ev.target.newpassword.value;
    const confirmpassword = ev.target.confirmpassword.value;
    if (newpassword !== confirmpassword)
      toast.error("Passwords do not match !");
    const formData = { id: id, token: token, password: newpassword };
    const res = await axios.post(URL, formData);
    const data = res.data;
    if (data.success === true) {
      toast.success(data.message);
      navigate("/login");
    } else toast.error(data.message);
  };

  return (
    <div className="w-full flex justify-center my-4">
      <div className="w-full max-w-lg p-6 bg-white border border-gray-200 rounded-lg shadow dark:bg-gray-800 dark:border-gray-700">
        <h5 className="text-2xl font-bold tracking-tight text-gray-900 dark:text-white text-center">
          Reset Password
        </h5>
        <form className="w-full flex max-w-md flex-col gap-4"onSubmit={handleResetPassword}>
          <div>
            <div className="mb-2 block">
              <label htmlFor="newpassword" className="text-sm font-medium required">
                New Password
              </label>
            </div>
            <input id="newpassword" name="newpassword" type="password" placeholder="New Password" required
              className="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-purple-500 focus:border-purple-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-purple-500 dark:focus:border-purple-500"
            />
          </div>
          <div>
            <div className="mb-2 block">
              <label htmlFor="confirmpassword" className="text-sm font-medium required">
                Confirm Password
              </label>
            </div>
            <input id="confirmpassword" name="confirmpassword" type="password" placeholder="Confirm Password" required
              className="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-purple-500 focus:border-purple-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-purple-500 dark:focus:border-purple-500"
            />
          </div>
          <div className="mt-2 block">
            <button type="submit" class="w-full focus:outline-none text-white bg-purple-600 hover:bg-purple-700 focus:ring-4 focus:ring-purple-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-purple-500 dark:hover:bg-purple-600 dark:focus:ring-purple-800">
              Submit
            </button>
          </div>

          <p className="text-center text-sm text-gray-500">
            Not yet registered?{" "}
            <a href="register" className="font-semibold leading-6 text-purple-600 hover:text-purple-500">
              Register Here
            </a>
          </p>
        </form>
      </div>
    </div>
  );
};

export default ResetPassword;
EOF

cat <<EOF > src/pages/Profile.js
// pages/Profile.js

import { useEffect } from "react";
import UserIcon from "../images/user.png";
import { redirect } from "react-router-dom";

const Profile = (props) => {
  const { isLoggedIn, name, email } = props;
  useEffect(() => {
    if (isLoggedIn === false) redirect("/");
  }, []);

  return (
    <div className="flex items-center justify-center mt-5">
      <div className="w-full max-w-lg p-6 bg-white border border-gray-200 rounded-lg shadow dark:bg-gray-800 dark:border-gray-700">
        <div className="flex flex-col items-center pb-10">
          <img alt="User Icon" width="96" height="96" src={UserIcon} className="mb-3 rounded-full shadow-lg"/>
          <h5 className="mb-1 text-xl font-medium text-gray-900 dark:text-white">{name}</h5>
          <span className="text-sm text-gray-500 dark:text-gray-400">{email}</span>
          <div className="mt-4 flex space-x-3 lg:mt-6">
            <a href="#"
              className="inline-flex items-center rounded-lg bg-purple-700 px-4 py-2 text-center text-sm font-medium text-white hover:bg-purple-800 focus:outline-none focus:ring-4 focus:ring-purple-300 dark:bg-purple-600 dark:hover:bg-purple-700 dark:focus:ring-purple-800">
              Add friend
            </a>
            <a href="#"
              className="inline-flex items-center rounded-lg border border-gray-300 bg-white px-4 py-2 text-center text-sm font-medium text-gray-900 hover:bg-gray-100 focus:outline-none focus:ring-4 focus:ring-gray-200 dark:border-gray-600 dark:bg-gray-800 dark:text-white dark:hover:border-gray-700 dark:hover:bg-gray-700 dark:focus:ring-gray-700">
              Message
            </a>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Profile;
EOF

mkdir -p src/images
curl -o src/images/user.png https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png