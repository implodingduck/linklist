
const Linklistitem = ( {item} ) => {
    return (<div className="linklistitem">
            <span><a href={item.url}>{item.url}</a></span><span>{item.description}</span>
        </div>
        )
}

export default Linklistitem