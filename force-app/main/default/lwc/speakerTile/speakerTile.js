/**
 * @File Name          : speakerTile.js
 * @Description        : 
 * @Author             : Amit Singh
 * @Group              : 
 * @Last Modified By   : Amit Singh
 * @Last Modified On   : 07-31-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/13/2020   A Singh     Initial Version
**/
import { LightningElement, api } from "lwc";
import utils from 'c/utils';
export default class SpeakerTile extends LightningElement {
  @api speaker;

  connectedCallback(){
    utils.foo();
  }
}