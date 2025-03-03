#!/usr/bin/python3

#Author: Blake Peden <bpeden@themissinglink.com.au>
#Date:   2017-08-20

# Read places from the ./places.json file and print travel distance to that
# location via car.

import requests
import sys
import json


baseAddress = "9-11 Dickson Avenue, Artarmon, Australia"

def main():
	with open('places.json') as f:
		locations = json.loads(f.read())
	for location in locations:
		dist = getDistance(locations[location])
		print("{}|{}|{}".format(location, locations[location], dist/1000.0))


def getDistance(address):
	api = "https://maps.googleapis.com/maps/api/directions/json?"
	apiKey = "AIzaSyCZel-4vHVTcBVpD29YYuNWnL1YkuT_zYw"

	request = "origin="+ baseAddress+ "&destination="+ address+ "&units=metric"+ "&key="+ apiKey

	url = api + request

	r = requests.get(url)

	try:
		response = r.json()
	except:
		#print("Couldn't decode json", file=sys.stderr)
		response = r.text
		exit
	
	distance = response['routes'][0]['legs'][0]['distance']['value']
	return distance
	
main()

