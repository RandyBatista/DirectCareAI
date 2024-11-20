import axios from 'axios';
import React, { useEffect, useState } from 'react';

function App() {
	const [message, setMessage] = useState('');
	const [items, setItems] = useState([]);
	const [newItem, setNewItem] = useState({ name: '', description: '' });

	// Fetch data from FastAPI on page load
	useEffect(() => {
		axios
			.get('http://localhost:8000/')
			.then((response) => {
				setMessage(response.data.message);
			})
			.catch((error) => {
				console.error('There was an error fetching the message:', error);
			});
	}, []);

	// Handle form submission to create new item
	const handleSubmit = (e) => {
		e.preventDefault();
		axios
			.post('http://localhost:8000/items/', newItem)
			.then((response) => {
				setItems([...items, response.data]);
				setNewItem({ name: '', description: '' });
			})
			.catch((error) => {
				console.error('There was an error submitting the item:', error);
			});
	};

	return (
		<div className="App">
			<h1>{message}</h1>

			<h2>Add New Item</h2>
			<form onSubmit={handleSubmit}>
				<input type="text" placeholder="Item Name" value={newItem.name} onChange={(e) => setNewItem({ ...newItem, name: e.target.value })} />
				<input type="text" placeholder="Item Description" value={newItem.description} onChange={(e) => setNewItem({ ...newItem, description: e.target.value })} />
				<button type="submit">Add Item</button>
			</form>

			<h2>Items:</h2>
			<ul>
				{items.map((item) => (
					<li key={item.id}>
						{item.name} - {item.description}
					</li>
				))}
			</ul>
		</div>
	);
}

export default App;
