import argparse
import json

parser = argparse.ArgumentParser()
parser.add_argument('-payload', '--payload', help='Payload from queue', required=True)

args, unknown = parser.parse_known_args()
args = vars(args)

queue_message_string = args['payload']
queue_message = json.loads(queue_message_string)

print(queue_message)