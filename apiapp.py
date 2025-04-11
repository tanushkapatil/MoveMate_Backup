from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, db
import requests

app = Flask(__name__)

# Initialize Firebase
cred = credentials.Certificate("firebase_config.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://your-project-id.firebaseio.com/'  # Replace this
})

# Google Maps API key
GOOGLE_API_KEY = 'AIzaSyCoe4L25do0dO-I40RsuieNCyP57-Wr88E'  # Add your key here

@app.route('/get_buses', methods=['POST'])
def get_buses():
    data = request.json
    start = data.get('start')
    destination = data.get('destination')

    if not start or not destination:
        return jsonify({'error': 'Missing start or destination'}), 400

    # Load all buses
    buses_ref = db.reference('buses').get()
    matching_buses = []

    for bus_id, bus_info in buses_ref.items():
        route = bus_info.get('route', [])
        if start in route and destination in route:
            start_index = route.index(start)
            end_index = route.index(destination)
            if start_index < end_index:
                current_location = bus_info.get('current_location', {})
                if 'lat' in current_location and 'lng' in current_location:
                    matching_buses.append({
                        'bus_id': bus_id,
                        'number': bus_info.get('number'),
                        'route': route,
                        'location': current_location,
                    })

    # Load all stops (used to get lat/lng of destination stop)
    stops_data = db.reference('stops').get()
    dest_coords = None
    for stop in stops_data.values():
        if stop.get('name') == destination:
            dest_coords = f"{stop['lat']},{stop['lng']}"
            break

    if not dest_coords:
        return jsonify({'error': 'Destination coordinates not found'}), 404

    # Get ETA and route polyline from Google Maps API
    for bus in matching_buses:
        origin = f"{bus['location']['lat']},{bus['location']['lng']}"
        params = {
            'origin': origin,
            'destination': dest_coords,
            'key': GOOGLE_API_KEY
        }

        response = requests.get('https://maps.googleapis.com/maps/api/directions/json', params=params).json()

        if response['status'] == 'OK':
            route = response['routes'][0]
            leg = route['legs'][0]
            bus['eta'] = leg['duration']['text']
            bus['polyline'] = route['overview_polyline']['points']
        else:
            bus['eta'] = 'Unavailable'
            bus['polyline'] = None

    return jsonify({'buses': matching_buses})

if __name__ == '__main__':
    app.run(debug=True)
