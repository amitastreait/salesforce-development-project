/**
 * @description       : 
 * @author            : Amit Singh
 * @group             : 
 * @last modified on  : 08-28-2020
 * @last modified by  : Amit Singh
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   07-31-2020   Amit Singh   Initial Version
**/
import { ShowToastEvent } from "lightning/platformShowToastEvent";

/**
 * Todo: Calls an Apex Class method and send the response to call back methods.
 * @param {*} _serveraction     - Name of the apex class action needs to execute.
 * @param {*} _params           - the list of parameters in JSON format
 * @param {*} _onsuccess        - Name of the method which will execute in success response
 * @param {*} _onerror          - Name of the method which will execute in error response
 */

const _servercall = (_serveraction, _params, _onsuccess, _onerror) => {
    if (!_params) {
      _params = {};
    }
    _serveraction(_params)
      .then(_result => {
        if (_result && _onsuccess) {
          _onsuccess(_result);
        }
      })
      .catch(_error => {
        if (_error && _onerror) {
          _onerror(_error);
        }
      });
  };  
/**
 * Todo: Prepare the toast object and return back to the calling JS class
 * @param {String} _title     - title of of the toast message
 * @param {String} _message   - message to display to the user
 * @param {String} _variant   - toast type either success/error/warning or info
 * @param {String} _mode      - defines either toast should auto disappear or it should stick.
*/

const _currencylist = ()=> {
  return [
    { label: 'USD', value: 'USD'} ,
    { label: 'AED', value: 'AED'} ,
    { label: 'AFN', value: 'AFN'} ,
    { label: 'ALL', value: 'ALL'} ,
    { label: 'AMD', value: 'AMD'} ,
    { label: 'ANG', value: 'ANG'} ,
    { label: 'AOA', value: 'AOA'} ,
    { label: 'ARS', value: 'ARS'} ,
    { label: 'AUD', value: 'AUD'} ,
    { label: 'AWG', value: 'AWG'} ,
    { label: 'AZN', value: 'AZN'} ,
    { label: 'BAM', value: 'BAM'} ,
    { label: 'BBD', value: 'BBD'} ,
    { label: 'BDT', value: 'BDT'} ,
    { label: 'BGN', value: 'BGN'} ,
    { label: 'BIF', value: 'BIF'} ,
    { label: 'BMD', value: 'BMD'} ,
    { label: 'BND', value: 'BND'} ,
    { label: 'BOB', value: 'BOB'} ,
    { label: 'BRL', value: 'BRL'} ,
    { label: 'BSD', value: 'BSD'} ,
    { label: 'BWP', value: 'BWP'} ,
    { label: 'BZD', value: 'BZD'} ,
    { label: 'CAD', value: 'CAD'} ,
    { label: 'CDF', value: 'CDF'} ,
    { label: 'CHF', value: 'CHF'} ,
    { label: 'CLP', value: 'CLP'} ,
    { label: 'CNY', value: 'CNY'} ,
    { label: 'COP', value: 'COP'} ,
    { label: 'CRC', value: 'CRC'} ,
    { label: 'CVE', value: 'CVE'} ,
    { label: 'CZK', value: 'CZK'} ,
    { label: 'DJF', value: 'DJF'} ,
    { label: 'DKK', value: 'DKK'} ,
    { label: 'DOP', value: 'DOP'} ,
    { label: 'DZD', value: 'DZD'} ,
    { label: 'EGP', value: 'EGP'} ,
    { label: 'ETB', value: 'ETB'} ,
    { label: 'EUR', value: 'EUR'} ,
    { label: 'FJD', value: 'FJD'} ,
    { label: 'FKP', value: 'FKP'} ,
    { label: 'GBP', value: 'GBP'} ,
    { label: 'GEL', value: 'GEL'} ,
    { label: 'GIP', value: 'GIP'} ,
    { label: 'GMD', value: 'GMD'} ,
    { label: 'GNF', value: 'GNF'} ,
    { label: 'GTQ', value: 'GTQ'} ,
    { label: 'GYD', value: 'GYD'} ,
    { label: 'HKD', value: 'HKD'} ,
    { label: 'HNL', value: 'HNL'} ,
    { label: 'HRK', value: 'HRK'} ,
    { label: 'HTG', value: 'HTG'} ,
    { label: 'HUF', value: 'HUF'} ,
    { label: 'IDR', value: 'IDR'} ,
    { label: 'ILS', value: 'ILS'} ,
    { label: 'INR', value: 'INR'} ,
    { label: 'ISK', value: 'ISK'} ,
    { label: 'JMD', value: 'JMD'} ,
    { label: 'JPY', value: 'JPY'} ,
    { label: 'KES', value: 'KES'} ,
    { label: 'KGS', value: 'KGS'} ,
    { label: 'KHR', value: 'KHR'} ,
    { label: 'KMF', value: 'KMF'} ,
    { label: 'KRW', value: 'KRW'} ,
    { label: 'KYD', value: 'KYD'} ,
    { label: 'KZT', value: 'KZT'} ,
    { label: 'LAK', value: 'LAK'} ,
    { label: 'LBP', value: 'LBP'} ,
    { label: 'LKR', value: 'LKR'} ,
    { label: 'LRD', value: 'LRD'} ,
    { label: 'LSL', value: 'LSL'} ,
    { label: 'MAD', value: 'MAD'} ,
    { label: 'MDL', value: 'MDL'} ,
    { label: 'MGA', value: 'MGA'} ,
    { label: 'MKD', value: 'MKD'} ,
    { label: 'MMK', value: 'MMK'} ,
    { label: 'MNT', value: 'MNT'} ,
    { label: 'MOP', value: 'MOP'} ,
    { label: 'MRO', value: 'MRO'} ,
    { label: 'MUR', value: 'MUR'} ,
    { label: 'MVR', value: 'MVR'} ,
    { label: 'MWK', value: 'MWK'} ,
    { label: 'MXN', value: 'MXN'} ,
    { label: 'MYR', value: 'MYR'} ,
    { label: 'MZN', value: 'MZN'} ,
    { label: 'NAD', value: 'NAD'} ,
    { label: 'NGN', value: 'NGN'} ,
    { label: 'NIO', value: 'NIO'} ,
    { label: 'NOK', value: 'NOK'} ,
    { label: 'NPR', value: 'NPR'} ,
    { label: 'NZD', value: 'NZD'} ,
    { label: 'PAB', value: 'PAB'} ,
    { label: 'PEN', value: 'PEN'} ,
    { label: 'PGK', value: 'PGK'} ,
    { label: 'PHP', value: 'PHP'} ,
    { label: 'PKR', value: 'PKR'} ,
    { label: 'PLN', value: 'PLN'} ,
    { label: 'PYG', value: 'PYG'} ,
    { label: 'QAR', value: 'QAR'} ,
    { label: 'RON', value: 'RON'} ,
    { label: 'RSD', value: 'RSD'} ,
    { label: 'RUB', value: 'RUB'} ,
    { label: 'RWF', value: 'RWF'} ,
    { label: 'SAR', value: 'SAR'} ,
    { label: 'SBD', value: 'SBD'} ,
    { label: 'SCR', value: 'SCR'} ,
    { label: 'SEK', value: 'SEK'} ,
    { label: 'SGD', value: 'SGD'} ,
    { label: 'SHP', value: 'SHP'} ,
    { label: 'SLL', value: 'SLL'} ,
    { label: 'SOS', value: 'SOS'} ,
    { label: 'SRD', value: 'SRD'} ,
    { label: 'STD', value: 'STD'} ,
    { label: 'SZL', value: 'SZL'} ,
    { label: 'THB', value: 'THB'} ,
    { label: 'TJS', value: 'TJS'} ,
    { label: 'TOP', value: 'TOP'} ,
    { label: 'TRY', value: 'TRY'} ,
    { label: 'TTD', value: 'TTD'} ,
    { label: 'TWD', value: 'TWD'} ,
    { label: 'TZS', value: 'TZS'} ,
    { label: 'UAH', value: 'UAH'} ,
    { label: 'UGX', value: 'UGX'} ,
    { label: 'UYU', value: 'UYU'} ,
    { label: 'UZS', value: 'UZS'} ,
    { label: 'VND', value: 'VND'} ,
    { label: 'VUV', value: 'VUV'} ,
    { label: 'WST', value: 'WST'} ,
    { label: 'XAF', value: 'XAF'} ,
    { label: 'XCD', value: 'XCD'} ,
    { label: 'XOF', value: 'XOF'} ,
    { label: 'XPF', value: 'XPF'} ,
    { label: 'YER', value: 'YER'} ,
    { label: 'ZAR', value: 'ZAR'} ,
    { label: 'ZMW', value: 'ZMW'} 
  ]
}

const _countryList = ()=>{
  return [
    { label: 'Australia', value: 'AU' },
    { label: 'Austria', value: 'AT' },
    { label: 'Belgium', value: 'BE' },
    { label: 'Bulgaria', value: 'BG' },
    { label: 'Canada', value: 'CA' },
    { label: 'Cyprus', value: 'CY' },
    { label: 'Czech Republic', value: 'CZ' },
    { label: 'Denmark', value: 'DK' },
    { label: 'Estonia', value: 'EE' },
    { label: 'Finland', value: 'FI' },
    { label: 'France', value: 'FR' },
    { label: 'Germany', value: 'DE' },
    { label: 'Greece', value: 'GR' },
    { label: 'Hong Kong', value: 'HK' },
    { label: 'Ireland', value: 'IE' },
    { label: 'Italy', value: 'IT' },
    { label: 'Japan', value: 'JP' },
    { label: 'Latvia', value: 'LV' },
    { label: 'Lithuania', value: 'LT' },
    { label: 'Luxembourg', value: 'LU' },
    { label: 'Malta', value: 'MT' },
    { label: 'Mexico', value: 'MX' },
    { label: 'Netherlands', value: 'NL' },
    { label: 'New Zealand', value: 'NZ' },
    { label: 'Norway', value: 'NO' },
    { label: 'Poland', value: 'PL' },
    { label: 'Portugal', value: 'PT' },
    { label: 'Romania', value: 'RO' },
    { label: 'Singapore', value: 'SG' },
    { label: 'Slovakia', value: 'SK' },
    { label: 'Slovenia', value: 'SI' },
    { label: 'Spain', value: 'ES' },
    { label: 'Sweden', value: 'SE' },
    { label: 'Switzerland', value: 'CH' },
    { label: 'United Kingdom', value: 'GB' },
    { label: 'United States', value: 'US' }
  ]
}

const _toastcall = (_title, _message, _variant, _mode) => {
    const _showToast = new ShowToastEvent({
      title: _title,
      message: _message,
      mode: _mode,
      variant: _variant
    });
    return _showToast;
};

/**
 * Todo: Parse the Error message and returns the parsed response to calling JS method.
 * @param {Array} errors  - Error Information
 */
const _reduceErrors = errors => {
    if (!Array.isArray(errors)) {
      errors = [errors];
    }
    return errors
  
      .filter(error => !!error)
  
      .map(error => {
        if (Array.isArray(error.body)) {
          return error.body.map(e => e.message);
        } else if (error.body && typeof error.body.message === "string") {
          return error.body.message;
        } else if (typeof error.message === "string") {
          return error.message;
        }
  
        return error.statusText;
      })
  
      .reduce((prev, curr) => prev.concat(curr), [])
  
      .filter(message => !!message);
  };
  
  

  export default {
    _servercall,
    _toastcall,
    _reduceErrors,
    _currencylist,
    _countryList
  };