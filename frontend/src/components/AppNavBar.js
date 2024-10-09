// components/AppNavbar.js

import { Avatar, Dropdown, Navbar } from 'flowbite-react';
import UserIcon from '../images/user.png';
import Logo from '../images/logo.png';
import { toast } from 'react-toastify';
import { useNavigate } from 'react-router-dom';

const AppNavBar = () => {
  let navigate = useNavigate();

  const name = localStorage.getItem('username');
  const email = localStorage.getItem('email');
  const isLoggedIn = name && email;
  const handleLogout = () => {
    localStorage.removeItem('username');
    localStorage.removeItem('email');
    navigate('/');
    toast.success('You are successfully logged out!');
  };

  return (
    <Navbar className="fixed w-full" fluid>
      <Navbar.Brand href="https://github.com/deanflanagan">
        <img src={Logo} className="mr-3 h-6 sm:h-9" alt="Flowbite React Logo" />
        <span className="self-center whitespace-nowrap text-3xl font-semibold dark:text-white">
          Math Quiz
        </span>
      </Navbar.Brand>
      {isLoggedIn && (
        <div className="flex md:order-2">
          <Dropdown
            arrowIcon={false}
            inline
            label={<Avatar alt="User settings" img={UserIcon} rounded />}
          >
            <Dropdown.Header>
              <span className="block text-sm">{name}</span>
              <span className="block truncate text-sm font-medium">
                {email}
              </span>
            </Dropdown.Header>
            <Dropdown.Item href="/profile">Profile</Dropdown.Item>
            <Dropdown.Item>Result</Dropdown.Item>
            <Dropdown.Divider />
            <Dropdown.Item onClick={handleLogout}>Log out</Dropdown.Item>
          </Dropdown>
          <Navbar.Toggle />
        </div>
      )}
      <Navbar.Collapse>
        {isLoggedIn && (
          <>
            <Navbar.Link href="/" className="text-lg">
              Home
            </Navbar.Link>
            <Navbar.Link href="#" className="text-lg">
              Result
            </Navbar.Link>
          </>
        )}
        {!isLoggedIn && (
          <Navbar.Link href="/login" className="text-lg">
            Login
          </Navbar.Link>
        )}
      </Navbar.Collapse>
    </Navbar>
  );
};

export default AppNavBar;
