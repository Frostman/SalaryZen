import argparse
import datetime
import json
import os
import time
from xml.dom import minidom as xml

import requests


def parse_args():
    def is_valid_file(parser, arg):
        if not os.access(arg, os.W_OK):
            parser.error("No write permissions for '%s'!" % arg)
        else:
            return open(arg, 'w')  # return an open file handle

    parser = argparse.ArgumentParser(description='Currency rates aggregator.')
    parser.add_argument("-o", dest="result_file", required=True,
                        help="Output file for aggregated rates", metavar="FILE",
                        type=lambda x: is_valid_file(parser, x))
    args = parser.parse_args()

    return args.result_file


def fetch_cb_and_alfa_bank_rates(result):
    def get_currency_name(currency_id):
        currency_ids = {
            "840": "USD",
            "978": "EUR",
        }

        return currency_ids[currency_id] if currency_id in currency_ids else null

    def cleanup_val(val):
        val = val.replace(',', '.').replace('down', '-').replace('up', '+')

        # calculate values like "12.34 - 56.78"
        if " - " in val:
            val_split = val.split(" - ")
            val = float(val_split[0]) - float(val_split[1])

        # convert val to float if possible
        try:
            val = float(val)
        except ValueError:
            pass

        # ensure that we have <= 4 digits precision
        if isinstance(val, float):
            val = float("{:.4f}".format(val))

        return val

    alfa_bank_url = "http://alfabank.ru/_/_currency.xml"
    response = requests.get(alfa_bank_url)

    if response.status_code != 200:
        print("Failed to access %s with status_code %s" % (alfa_bank_url, response.status_code))
        exit(-1)

    response = xml.parseString(response.text)

    for rate_tag in response.getElementsByTagName("rates"):
        rate_type = rate_tag.getAttribute("type")

        items = rate_tag.getElementsByTagName("item")

        if rate_type not in ["non-cash", "cb"]:
            continue

        for item in items:
            currency_name = get_currency_name(item.getAttribute("currency-id"))
            if currency_name:
                target = result['cb' if rate_type == 'cb' else 'alfa-bank']
                if currency_name not in target:
                    target[currency_name] = {}
                target = target[currency_name]
                subType = 'official' if rate_type == 'cb' else rate_type
                if subType not in target:
                    target[subType] = {}
                target = target[subType]

                if item.getAttribute("value"):
                    target['rate'] = cleanup_val(item.getAttribute("value"))
                else:
                    target['sellRate'] = cleanup_val(item.getAttribute("value-selling"))
                    target['buyRate'] = cleanup_val(item.getAttribute("value-buying"))

                target['rise'] = cleanup_val(item.getAttribute("rise"))
                target['rise_dir'] = cleanup_val(item.getAttribute("rise_dir"))


def write_timestamp(result):
    result["timestamp"] = time.time()


def main():
    result_file = parse_args()

    result = {
        "alfa-bank": {},
        "cb": {},
    }

    fetch_cb_and_alfa_bank_rates(result)
    write_timestamp(result)

    print "New data aggregated at %s" % datetime.datetime.now()

    result_file.write(json.dumps(result))
    result_file.close()


if __name__ == "__main__":
    main()
